import 'package:flutter/material.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_recurrence_type.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_status.dart';

import '../../../../../app/theme/app_icons.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_chip.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/enum/task_mode.dart';
import '../../style/task_style.dart';
import '../task_status_chip.dart';

class TaskDetailHeader extends StatelessWidget {
  final Task task;

  const TaskDetailHeader({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final isDone = task.status.isDone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            TaskStatusChip(status: task.status),
            AppChip.status(
              label: _modeDetailLabel(task.taskMode),
              icon: TaskStyle.modeIcon(task.taskMode),
              color: TaskStyle.modeColor(task.taskMode),
            ),
            if (task.recurrenceType.isRecurring)
              AppChip.metadata(
                label: task.recurrenceType.label,
                icon: AppIcons.recurrence,
              ),
            if (task.paused)
              AppChip.metadata(label: 'Paused', icon: AppIcons.paused),
            if (task.archived)
              AppChip.metadata(label: 'Archived', icon: AppIcons.archive),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          task.title,
          style: AppTextStyles.pageTitle(context).copyWith(
            decoration: TaskStyle.titleDecoration(completed: isDone),
            color: TaskStyle.titleColor(
              context,
              completed: isDone,
              archived: task.archived,
              paused: task.paused,
            ),
          ),
        ),
      ],
    );
  }

  String _modeDetailLabel(TaskMode mode) {
    switch (mode) {
      case TaskMode.standard:
        return 'Standard';
      case TaskMode.urgent:
        return 'Urgent';
      case TaskMode.daily:
        return "Today's Focus";
      case TaskMode.progress:
        return 'Progress';
    }
  }
}
