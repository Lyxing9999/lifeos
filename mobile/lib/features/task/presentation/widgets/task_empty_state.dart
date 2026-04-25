import 'package:flutter/material.dart';

import '../../../../core/widgets/app_empty_view.dart';
import '../../content/task_copy.dart';

class TaskEmptyState extends StatelessWidget {
  final VoidCallback? onCreateTask;
  final bool centered;

  const TaskEmptyState({super.key, this.onCreateTask, this.centered = true});

  @override
  Widget build(BuildContext context) {
    return AppEmptyView(
      icon: Icons.checklist_outlined,
      title: TaskCopy.emptyTitle,
      subtitle: TaskCopy.emptySubtitle,
      actionLabel: onCreateTask == null ? null : TaskCopy.createAction,
      actionIcon: Icons.playlist_add_check_rounded,
      onAction: onCreateTask,
      centered: centered,
    );
  }
}
