import 'package:flutter/material.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_status.dart';

import '../../../../../app/theme/app_icons.dart';
import '../../../../../app/theme/app_motion.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/widgets/animated_list_item.dart';
import '../../../../../core/widgets/app_empty_view.dart';
import '../../../../../core/widgets/app_loading_view.dart';
import '../../../application/task_state.dart';
import '../../../content/task_copy.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/enum/task_filter.dart';
import '../task_card.dart';
import '../task_empty_state.dart';

class TaskSliverList extends StatelessWidget {
  final TaskState state;
  final List<Task> tasks;
  final DateTime selectedDate;
  final TaskFilter selectedFilter;
  final double bottomPadding;

  final Future<void> Function() onRetry;
  final VoidCallback? onCreateTask;
  final ValueChanged<String> onOpenTask;

  final Future<void> Function(String taskId, DateTime selectedDate)
  onCompleteTask;

  final Future<void> Function(String taskId, DateTime selectedDate)
  onReopenTask;

  const TaskSliverList({
    super.key,
    required this.state,
    required this.tasks,
    required this.selectedDate,
    required this.selectedFilter,
    required this.bottomPadding,
    required this.onRetry,
    required this.onCreateTask,
    required this.onOpenTask,
    required this.onCompleteTask,
    required this.onReopenTask,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && tasks.isEmpty) {
      return SliverAppLoadingList(bottomPadding: bottomPadding);
    }

    if (state.errorMessage != null && tasks.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: AppEmptyView(
          icon: AppIcons.tasks,
          title: TaskCopy.loadErrorTitle,
          subtitle: state.errorMessage ?? TaskCopy.loadErrorFallback,
          actionLabel: TaskCopy.retry,
          actionIcon: AppIcons.refresh,
          onAction: onRetry,
          centered: false,
        ),
      );
    }

    if (tasks.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: TaskEmptyState(
          filter: selectedFilter,
          onCreateTask: onCreateTask,
          centered: false,
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.md,
        AppSpacing.pageHorizontal,
        bottomPadding,
      ),
      sliver: SliverList.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];

          final canComplete = _canCompleteTask(task);
          final canReopen = _canReopenTask(task);

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.listItemGap),
            child: AnimatedListItem(
              index: index,
              baseDelay: AppMotion.listBaseDelay,
              staggerDelay: AppMotion.listStaggerDelay,
              child: TaskCard(
                task: task,
                onTap: () => onOpenTask(task.id),

                // Due + Inbox allow quick complete.
                // All / Library is intentionally read/manage from detail.
                onComplete: canComplete
                    ? () => onCompleteTask(task.id, selectedDate)
                    : null,

                // Done allows quick reopen.
                onReopen: canReopen
                    ? () => onReopenTask(task.id, selectedDate)
                    : null,

                compactCompleted: _compactCompleted,
                showLibraryIntent: selectedFilter == TaskFilter.all,
              ),
            ),
          );
        },
      ),
    );
  }

  bool get _compactCompleted {
    switch (selectedFilter) {
      case TaskFilter.done:
      case TaskFilter.history:
        return true;
      case TaskFilter.due:
      case TaskFilter.inbox:
      case TaskFilter.all:
      case TaskFilter.paused:
      case TaskFilter.archive:
        return false;
    }
  }

  bool _canCompleteTask(Task task) {
    if (task.status.isDone || task.archived || task.paused) {
      return false;
    }

    switch (selectedFilter) {
      case TaskFilter.due:
      case TaskFilter.inbox:
        return true;

      // Task library is a readonly/manage surface.
      // User opens detail to edit, pause, archive, or manage plan.
      case TaskFilter.all:
        return false;

      case TaskFilter.done:
      case TaskFilter.history:
      case TaskFilter.paused:
      case TaskFilter.archive:
        return false;
    }
  }

  bool _canReopenTask(Task task) {
    if (!task.status.isDone || task.archived || task.paused) {
      return false;
    }

    switch (selectedFilter) {
      case TaskFilter.done:
        return true;

      // History is mainly a record. If you want “Reopen today”
      // from history, change this to true.
      case TaskFilter.history:
        return false;

      case TaskFilter.due:
      case TaskFilter.inbox:
      case TaskFilter.all:
      case TaskFilter.paused:
      case TaskFilter.archive:
        return false;
    }
  }
}
