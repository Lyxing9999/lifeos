import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../domain/enum/task_mode.dart';
import '../../domain/enum/task_priority.dart';
import '../../domain/enum/task_status.dart';
import '../../domain/model/task.dart';
import 'task_progress_bar.dart';
import 'task_status_chip.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback? onComplete;
  final bool compactCompleted;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    this.onComplete,
    this.compactCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task.status.isDone;
    final canComplete = onComplete != null && !isDone;

    final cardWidget = Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.cardInsetsSm,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: GestureDetector(
                  onTap: onComplete == null
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          onComplete?.call();
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone ? AppColors.green : Colors.transparent,
                      border: isDone
                          ? null
                          : Border.all(
                              color: Theme.of(context).colorScheme.outline,
                              width: 1.5,
                            ),
                    ),
                    child: isDone
                        ? Icon(
                            Icons.check_rounded,
                            size: 12,
                            color: Theme.of(context).colorScheme.onPrimary,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: AppTextStyles.cardTitle(context).copyWith(
                              color: isDone
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant
                                  : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        TaskStatusChip(status: task.status),
                      ],
                    ),
                    if ((task.description ?? '').trim().isNotEmpty &&
                        !compactCompleted) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        task.description!,
                        style: AppTextStyles.bodySecondary(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        AppChip.metadata(
                          label: task.taskMode.label,
                          icon: _modeIcon(task.taskMode),
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
                        if (task.dueDate != null || task.dueDateTime != null)
                          AppChip.metadata(
                            label: _dueLabel(task),
                            icon: Icons.calendar_today_outlined,
                            color: _dueColor(task),
                          ),
                        ...task.tags
                            .take(2)
                            .map(
                              (tag) => AppChip.metadata(
                                label: tag.name,
                                icon: Icons.sell_outlined,
                              ),
                            ),
                      ],
                    ),
                    if (!compactCompleted &&
                        task.taskMode == TaskMode.progress) ...[
                      const SizedBox(height: AppSpacing.sm),
                      TaskProgressBar(progress: task.progressPercent),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!canComplete) return cardWidget;

    return Dismissible(
      key: ValueKey('task-swipe-${task.id}'),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        HapticFeedback.mediumImpact();
        onComplete?.call();
        // Return false — we handle state update via onComplete callback.
        return false;
      },
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.green.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppSpacing.lg),
        child: const Icon(
          Icons.check_circle_outline_rounded,
          color: AppColors.green,
          size: 24,
        ),
      ),
      child: cardWidget,
    );
  }

  IconData _modeIcon(TaskMode mode) {
    switch (mode) {
      case TaskMode.standard:
        return Icons.checklist_rtl_outlined;
      case TaskMode.daily:
        return Icons.repeat_rounded;
      case TaskMode.urgent:
        return Icons.notification_important_outlined;
      case TaskMode.progress:
        return Icons.trending_up_rounded;
    }
  }

  Color? _priorityColor(String priorityApiValue) {
    switch (priorityApiValue) {
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

  String _dueLabel(Task task) {
    final due = task.dueDateTime ?? task.dueDate;
    if (due == null) return 'No due';

    final m = due.month.toString().padLeft(2, '0');
    final d = due.day.toString().padLeft(2, '0');

    if (task.dueDateTime != null) {
      final hh = due.hour.toString().padLeft(2, '0');
      final mm = due.minute.toString().padLeft(2, '0');
      return '$m/$d $hh:$mm';
    }

    return '$m/$d';
  }

  Color? _dueColor(Task task) {
    if (task.status.isDone) return null;
    final due = task.dueDateTime ?? task.dueDate;
    if (due == null) return null;

    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(due.year, due.month, due.day);

    if (dueDay.isBefore(day)) {
      return AppColors.danger;
    }
    if (dueDay.isAtSameMomentAs(day)) {
      return AppColors.warning;
    }
    return null;
  }
}
