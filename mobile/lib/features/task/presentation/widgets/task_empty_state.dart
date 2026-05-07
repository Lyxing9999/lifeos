import 'package:flutter/material.dart';

import '../../../../app/theme/app_icons.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../content/task_copy.dart';
import '../../domain/enum/task_filter.dart';

class TaskEmptyState extends StatelessWidget {
  final TaskFilter filter;
  final VoidCallback? onCreateTask;
  final bool centered;

  const TaskEmptyState({
    super.key,
    required this.filter,
    this.onCreateTask,
    this.centered = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmptyView(
      icon: _icon,
      title: _title,
      subtitle: _subtitle,
      actionLabel: onCreateTask == null ? null : TaskCopy.createAction,
      actionIcon: AppIcons.addTask,
      onAction: onCreateTask,
      centered: centered,
    );
  }

  IconData get _icon {
    switch (filter) {
      case TaskFilter.due:
        return AppIcons.date;
      case TaskFilter.inbox:
        return AppIcons.inbox;
      case TaskFilter.all:
        return AppIcons.tasks;
      case TaskFilter.done:
        return AppIcons.complete;
      case TaskFilter.paused:
        return AppIcons.paused;
      case TaskFilter.history:
        return AppIcons.history;
      case TaskFilter.archive:
        return AppIcons.archive;
    }
  }

  String get _title {
    switch (filter) {
      case TaskFilter.due:
        return 'No due tasks';
      case TaskFilter.inbox:
        return TaskCopy.emptyInboxTitle;
      case TaskFilter.all:
        return TaskCopy.emptyAllTitle;
      case TaskFilter.done:
        return TaskCopy.emptyDoneTitle;
      case TaskFilter.paused:
        return TaskCopy.emptyPausedTitle;
      case TaskFilter.history:
        return TaskCopy.emptyHistoryTitle;
      case TaskFilter.archive:
        return TaskCopy.emptyArchiveTitle;
    }
  }

  String get _subtitle {
    switch (filter) {
      case TaskFilter.due:
        return 'Tasks with due dates, repeat rules, or schedule links appear here.';
      case TaskFilter.inbox:
        return TaskCopy.emptyInboxSubtitle;
      case TaskFilter.all:
        return TaskCopy.emptyAllSubtitle;
      case TaskFilter.done:
        return TaskCopy.emptyDoneSubtitle;
      case TaskFilter.paused:
        return TaskCopy.emptyPausedSubtitle;
      case TaskFilter.history:
        return TaskCopy.emptyHistorySubtitle;
      case TaskFilter.archive:
        return TaskCopy.emptyArchiveSubtitle;
    }
  }
}
