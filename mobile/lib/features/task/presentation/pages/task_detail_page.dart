import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../auth/application/auth_providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../application/task_providers.dart';
import '../../content/task_copy.dart';
import '../../domain/enum/task_mode.dart';
import '../../domain/enum/task_priority.dart';
import '../../domain/enum/task_recurrence_type.dart';
import '../../domain/enum/task_status.dart';
import '../../domain/model/task.dart';
import '../widgets/task_progress_bar.dart';
import '../widgets/task_status_chip.dart';
import 'edit_task_page.dart';

class TaskDetailPage extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailPage({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends ConsumerState<TaskDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userId = ref.read(currentUserIdProvider);
      ref
          .read(taskNotifierProvider.notifier)
          .loadById(userId: userId, taskId: widget.taskId);
    });
  }

  Future<void> _confirmDelete(String userId, String taskId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text('This task will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await ref
        .read(taskNotifierProvider.notifier)
        .deleteTask(userId: userId, taskId: taskId);

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _complete(String userId, String taskId) async {
    HapticFeedback.mediumImpact();
    await ref
        .read(taskNotifierProvider.notifier)
        .completeTask(userId: userId, taskId: taskId);
    await ref
        .read(taskNotifierProvider.notifier)
        .loadById(userId: userId, taskId: taskId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskNotifierProvider);
    final task = state.selectedTask;
    final userId = ref.read(currentUserIdProvider);

    if (task == null || task.id != widget.taskId) {
      return const Scaffold(
        body: AppLoadingView(
          title: TaskCopy.loadingTaskTitle,
          subtitle: TaskCopy.loadingTaskSubtitle,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final result = await navigator.push(
                MaterialPageRoute(
                  builder: (_) => EditTaskPage(taskId: task.id),
                ),
              );
              if (!mounted) return;
              if (result is String && result.trim().isNotEmpty) {
                messenger.showSnackBar(SnackBar(content: Text(result)));
              }
              await ref
                  .read(taskNotifierProvider.notifier)
                  .loadById(userId: userId, taskId: task.id);
            },
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(userId, task.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal,
          AppSpacing.sm,
          AppSpacing.pageHorizontal,
          AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(task: task),
            const SizedBox(height: AppSpacing.md),
            _MetaSection(task: task),
            if ((task.description ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _NotesSection(description: task.description!),
            ],
            if (task.tags.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _TagSection(task: task),
            ],
            if (!task.status.isDone) ...[
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () => _complete(userId, task.id),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Mark as Complete'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Task task;

  const _Header({required this.task});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            task.title,
            style: AppTextStyles.pageTitle(context).copyWith(
              decoration: task.status.isDone
                  ? TextDecoration.lineThrough
                  : null,
              color: task.status.isDone
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : null,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: TaskStatusChip(status: task.status),
        ),
      ],
    );
  }
}

class _MetaSection extends StatelessWidget {
  final Task task;

  const _MetaSection({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                AppChip.metadata(
                  label: task.taskMode.label,
                  icon: Icons.category_outlined,
                ),
                AppChip.metadata(
                  label: task.priority.label,
                  icon: Icons.flag_outlined,
                  color: _priorityColor(task.priority.apiValue),
                ),
                if ((task.category ?? '').trim().isNotEmpty)
                  AppChip.metadata(
                    label: task.category!,
                    icon: Icons.label_outline,
                  ),
                if (task.archived)
                  const AppChip.metadata(
                    label: 'Archived',
                    icon: Icons.archive_outlined,
                  ),
              ],
            ),
            if (task.taskMode.name == 'progress') ...[
              const SizedBox(height: AppSpacing.md),
              TaskProgressBar(progress: task.progressPercent),
            ],
            const SizedBox(height: AppSpacing.md),
            _MetaRow(
              icon: Icons.calendar_today_outlined,
              label: 'Due date',
              value: _dateLabel(task.dueDate),
            ),
            const SizedBox(height: AppSpacing.sm),
            _MetaRow(
              icon: Icons.schedule,
              label: 'Due time',
              value: _dateTimeLabel(task.dueDateTime),
            ),
            const SizedBox(height: AppSpacing.sm),
            _MetaRow(
              icon: Icons.repeat_rounded,
              label: 'Recurrence',
              value: task.recurrenceType.label,
            ),
            if (task.recurrenceType.isRecurring) ...[
              const SizedBox(height: AppSpacing.sm),
              _MetaRow(
                icon: Icons.play_circle_outline,
                label: 'Recurrence start',
                value: _dateLabel(task.recurrenceStartDate),
              ),
              const SizedBox(height: AppSpacing.sm),
              _MetaRow(
                icon: Icons.stop_circle_outlined,
                label: 'Recurrence end',
                value: _dateLabel(task.recurrenceEndDate),
              ),
            ],
            if (task.recurrenceDaysOfWeek.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              _MetaRow(
                icon: Icons.view_week_outlined,
                label: 'Recurrence days',
                value: task.recurrenceDaysOfWeek.join(', '),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            _MetaRow(
              icon: Icons.account_tree_outlined,
              label: 'Linked schedule block',
              value: (task.linkedScheduleBlockId ?? '').trim().isEmpty
                  ? 'Not linked'
                  : task.linkedScheduleBlockId!,
            ),
          ],
        ),
      ),
    );
  }

  String _dateLabel(DateTime? date) {
    if (date == null) return 'Not set';
    return DateFormat.yMMMd().format(date);
  }

  String _dateTimeLabel(DateTime? dateTime) {
    if (dateTime == null) return 'Not set';
    return DateFormat.yMMMd().add_jm().format(dateTime.toLocal());
  }

  Color? _priorityColor(String value) {
    switch (value) {
      case 'LOW':
        return AppColors.slate;
      case 'MEDIUM':
        return AppColors.blue;
      case 'HIGH':
        return AppColors.warning;
      default:
        return null;
    }
  }
}

class _TagSection extends StatelessWidget {
  final Task task;

  const _TagSection({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tags', style: AppTextStyles.sectionHeader(context)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: task.tags
                  .map(
                    (tag) => AppChip.metadata(
                      label: tag.name,
                      icon: Icons.sell_outlined,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  final String description;

  const _NotesSection({required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description', style: AppTextStyles.sectionHeader(context)),
            const SizedBox(height: AppSpacing.sm),
            Text(description, style: AppTextStyles.bodyPrimary(context)),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(label, style: AppTextStyles.bodySecondary(context)),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.cardTitle(context),
          ),
        ),
      ],
    );
  }
}
