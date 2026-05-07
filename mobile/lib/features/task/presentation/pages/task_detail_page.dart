import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/app_button.dart';
import '../../application/task_providers.dart';
import '../../content/task_copy.dart';
import '../../domain/entities/task.dart';
import '../../domain/enum/task_status.dart';
import '../../domain/enum/task_state_action.dart';
import '../../domain/helper/task_state_helper.dart';
import '../widgets/detail/task_detail_action_bar.dart';
import '../widgets/detail/task_detail_header.dart';
import '../widgets/detail/task_detail_meta_section.dart';
import '../widgets/detail/task_detail_notes_section.dart';
import '../widgets/detail/task_detail_tags_section.dart';
import 'edit_task_page.dart';

enum _TaskDetailMenuAction { pause, resume, restore, remove }

enum _TaskRemoveAction { primary, deletePermanently, cancel }

class TaskDetailPage extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailPage({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends ConsumerState<TaskDetailPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  BuildContext get _feedbackContext => _scaffoldKey.currentContext ?? context;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final date = ref.read(taskNotifierProvider).selectedDate;
      ref
          .read(taskNotifierProvider.notifier)
          .loadById(taskId: widget.taskId, date: date);
    });
  }

  Future<_TaskRemoveAction?> _showRemoveDialog(bool isArchived) {
    return showDialog<_TaskRemoveAction>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.cardLg),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: 0.84),
                  borderRadius: BorderRadius.circular(AppRadius.cardLg),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.42),
                    width: 0.9,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.16),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(AppRadius.iconLg),
                        border: Border.all(
                          color: AppColors.danger.withValues(alpha: 0.20),
                          width: 0.8,
                        ),
                      ),
                      child: Icon(
                        isArchived ? AppIcons.reopen : AppIcons.delete,
                        color: AppColors.danger,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      TaskCopy.removeDialogTitle,
                      style: AppTextStyles.cardTitle(
                        ctx,
                      ).copyWith(color: scheme.onSurface, letterSpacing: -0.15),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      isArchived
                          ? 'Restore this task or delete it permanently.'
                          : 'Archive this task to hide it from active views, or delete it permanently.',
                      style: AppTextStyles.bodySecondary(ctx),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton.secondary(
                            label: TaskCopy.removeDialogCancel,
                            onPressed: () =>
                                Navigator.of(ctx).pop(_TaskRemoveAction.cancel),
                            fullWidth: true,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: AppButton.destructive(
                            label: TaskCopy.removeDialogDelete,
                            onPressed: () => Navigator.of(
                              ctx,
                            ).pop(_TaskRemoveAction.deletePermanently),
                            fullWidth: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton.primary(
                        label: isArchived
                            ? TaskCopy.removeDialogRestore
                            : TaskCopy.removeDialogArchive,
                        onPressed: () =>
                            Navigator.of(ctx).pop(_TaskRemoveAction.primary),
                        fullWidth: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _runPrimaryTaskAction({required Task task}) async {
    if (task.archived) {
      await ref
          .read(taskMutationCoordinatorProvider)
          .restoreTask(taskId: task.id);

      if (!mounted) return;
      _finishWithStateMessage(TaskCopy.successRestored);
      return;
    }

    await ref
        .read(taskMutationCoordinatorProvider)
        .archiveTask(taskId: task.id);

    if (!mounted) return;
    _finishWithStateMessage(TaskCopy.successArchived);
  }

  Future<void> _deleteTask({required Task task}) async {
    await ref.read(taskMutationCoordinatorProvider).deleteTask(taskId: task.id);

    if (!mounted) return;
    _finishWithStateMessage(TaskCopy.successDeletedPermanently);
  }

  /// Unified handler for task state actions (pause/resume).
  /// Ensures consistent, predictable, and senior-level safe behavior.
  /// Uses TaskStateAction enum for symmetric state transitions.
  Future<void> _handleTaskStateAction({
    required Task task,
    required TaskStateAction action,
  }) async {
    try {
      final coordinator = ref.read(taskMutationCoordinatorProvider);

      switch (action) {
        case TaskStateAction.pause:
          await coordinator.pauseTask(taskId: task.id);
          if (!mounted) return;
          _finishWithStateMessage(TaskCopy.successPaused);

        case TaskStateAction.resume:
          await coordinator.resumeTask(taskId: task.id);
          if (!mounted) return;
          _finishWithStateMessage(TaskCopy.successResumed);
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Task state action failed: $e');
    }
  }

  Future<void> _openRemoveDialog({required Task task}) async {
    final action = await _showRemoveDialog(task.archived);

    if (action == null || action == _TaskRemoveAction.cancel || !mounted) {
      return;
    }

    if (action == _TaskRemoveAction.primary) {
      await _runPrimaryTaskAction(task: task);
      return;
    }

    await _deleteTask(task: task);
  }

  Future<void> _complete(Task task) async {
    HapticFeedback.mediumImpact();
    final selectedDate = ref.read(taskNotifierProvider).selectedDate;

    await ref
        .read(taskMutationCoordinatorProvider)
        .completeTask(taskId: task.id, date: selectedDate);

    if (!mounted) return;
    final latest = ref.read(taskNotifierProvider);

    if (latest.errorMessage != null) {
      AppFeedback.error(_feedbackContext, message: latest.errorMessage!);
      return;
    }
    await ref
        .read(taskNotifierProvider.notifier)
        .loadById(taskId: task.id, date: selectedDate);
  }

  Future<void> _reopen(Task task) async {
    HapticFeedback.mediumImpact();
    final selectedDate = ref.read(taskNotifierProvider).selectedDate;

    await ref
        .read(taskMutationCoordinatorProvider)
        .reopenTask(taskId: task.id, date: selectedDate);

    if (!mounted) return;
    final latest = ref.read(taskNotifierProvider);

    if (latest.errorMessage != null) {
      AppFeedback.error(_feedbackContext, message: latest.errorMessage!);
      return;
    }

    await ref
        .read(taskNotifierProvider.notifier)
        .loadById(taskId: task.id, date: selectedDate);
  }

  Future<void> _openEdit(Task task) async {
    final navigator = Navigator.of(context);

    final result = await navigator.push(
      MaterialPageRoute(builder: (_) => EditTaskPage(taskId: task.id)),
    );

    if (!mounted) return;

    if (result is String && result.trim().isNotEmpty) {
      AppFeedback.success(
        _feedbackContext,
        title: 'Task updated',
        message: result.trim(),
      );
    }

    await ref.read(taskNotifierProvider.notifier).loadById(taskId: task.id);
  }

  void _finishWithStateMessage(String fallback) {
    final latest = ref.read(taskNotifierProvider);

    if (latest.errorMessage != null) {
      AppFeedback.error(_feedbackContext, message: latest.errorMessage!);
      return;
    }

    Navigator.of(context).pop(latest.successMessage ?? fallback);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskNotifierProvider);
    final task = state.selectedTask;

    if (task == null || task.id != widget.taskId) {
      return const Scaffold(
        body: AppLoadingView(
          title: TaskCopy.loadingTaskTitle,
          subtitle: TaskCopy.loadingTaskSubtitle,
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Task'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(AppIcons.edit),
            onPressed: () => _openEdit(task),
          ),
          PopupMenuButton<_TaskDetailMenuAction>(
            onSelected: (action) async {
              switch (action) {
                case _TaskDetailMenuAction.pause:
                  await _handleTaskStateAction(
                    task: task,
                    action: TaskStateAction.pause,
                  );
                  return;
                case _TaskDetailMenuAction.resume:
                  await _handleTaskStateAction(
                    task: task,
                    action: TaskStateAction.resume,
                  );
                  return;
                case _TaskDetailMenuAction.restore:
                  await _runPrimaryTaskAction(task: task);
                  return;
                case _TaskDetailMenuAction.remove:
                  await _openRemoveDialog(task: task);
                  return;
              }
            },
            itemBuilder: (context) {
              return [
                if (!task.archived && task.paused)
                  const PopupMenuItem(
                    value: _TaskDetailMenuAction.resume,
                    child: Text(TaskCopy.menuResume),
                  ),
                if (!task.archived && !task.paused && !task.status.isDone)
                  const PopupMenuItem(
                    value: _TaskDetailMenuAction.pause,
                    child: Text(TaskCopy.menuPause),
                  ),
                if (task.archived)
                  const PopupMenuItem(
                    value: _TaskDetailMenuAction.restore,
                    child: Text(TaskCopy.menuRestore),
                  ),
                const PopupMenuItem(
                  value: _TaskDetailMenuAction.remove,
                  child: Text(TaskCopy.menuRemove),
                ),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal,
          AppSpacing.sm,
          AppSpacing.pageHorizontal,
          AppSpacing.navBarClearance(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TaskDetailHeader(task: task),
            const SizedBox(height: AppSpacing.md),
            TaskDetailMetaSection(task: task),
            if ((task.description ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              TaskDetailNotesSection(description: task.description!.trim()),
            ],
            if (task.tags.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              TaskDetailTagsSection(task: task),
            ],

            // --- The Fix: Guard the Complete/Reopen actions based on intent state ---
            TaskDetailActionBar(
              task: task,
              onComplete: task.isActive ? () => _complete(task) : null,
              onPause: TaskStateHelper.canPause(task)
                  ? () => _handleTaskStateAction(
                      task: task,
                      action: TaskStateAction.pause,
                    )
                  : null,
              onReopen: (task.isDone && !task.archived)
                  ? () => _reopen(task)
                  : null,
              onResume: task.paused
                  ? () => _handleTaskStateAction(
                      task: task,
                      action: TaskStateAction.resume,
                    )
                  : null,
              onRestore: task.archived
                  ? () => _runPrimaryTaskAction(task: task)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
