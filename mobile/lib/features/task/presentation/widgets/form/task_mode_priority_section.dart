import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/widgets/app_chip.dart';
import '../../../../../core/widgets/app_form_section.dart';
import '../../../content/task_copy.dart';
import '../../../domain/enum/task_mode.dart';
import '../../../domain/enum/task_priority.dart';

class TaskModePrioritySection extends StatelessWidget {
  final TaskMode taskMode;
  final TaskPriority priority;
  final ValueChanged<TaskMode> onModeChanged;
  final ValueChanged<TaskPriority> onPriorityChanged;

  const TaskModePrioritySection({
    super.key,
    required this.taskMode,
    required this.priority,
    required this.onModeChanged,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppFormSection(
      title: TaskCopy.formSectionHow,
      subtitle: _modeSubtitle(taskMode),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Task type', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: TaskMode.values.map((mode) {
              return AppChip.filter(
                label: _modeLabel(mode),
                selected: taskMode == mode,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onModeChanged(mode);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Priority', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: TaskPriority.values.map((item) {
              return AppChip.filter(
                label: item.label,
                selected: priority == item,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onPriorityChanged(item);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _modeLabel(TaskMode mode) {
    switch (mode) {
      case TaskMode.standard:
        return 'Standard';
      case TaskMode.urgent:
        return 'Urgent';
      case TaskMode.daily:
        return 'Daily focus';
      case TaskMode.progress:
        return 'Progress';
    }
  }

  String _modeSubtitle(TaskMode mode) {
    switch (mode) {
      case TaskMode.standard:
        return 'Normal task. Use Repeat below if it should recur.';
      case TaskMode.urgent:
        return 'Important task that should stand out.';
      case TaskMode.daily:
        return 'Routine-like task. This does not repeat unless Repeat is enabled.';
      case TaskMode.progress:
        return 'Track percentage progress from 0 to 100.';
    }
  }
}
