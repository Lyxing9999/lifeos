import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../../app/theme/app_icons.dart';
import '../../../../../core/widgets/app_form_section.dart';
import '../../../../../core/widgets/app_picker_tile.dart';
import '../../../content/task_copy.dart';
import '../../../domain/enum/task_mode.dart';

class TaskDueSection extends StatelessWidget {
  final TaskMode taskMode;
  final DateTime? dueDate;
  final bool useDueTime;
  final TimeOfDay? dueTime;
  final bool recurrenceActive;

  final VoidCallback onPickDueDate;
  final VoidCallback onClearDueDate;
  final ValueChanged<bool> onUseDueTimeChanged;
  final VoidCallback onPickDueTime;

  const TaskDueSection({
    super.key,
    required this.taskMode,
    required this.dueDate,
    required this.useDueTime,
    required this.dueTime,
    required this.recurrenceActive,
    required this.onPickDueDate,
    required this.onClearDueDate,
    required this.onUseDueTimeChanged,
    required this.onPickDueTime,
  });

  @override
  Widget build(BuildContext context) {
    return AppFormSection(
      title: TaskCopy.formSectionWhen,
      subtitle: _subtitle,
      child: Column(
        children: [
          AppPickerTile(
            label: 'Due date',
            icon: AppIcons.date,
            value: dueDate == null
                ? 'No due date'
                : DateFormat.yMMMd().format(dueDate!),
            onTap: onPickDueDate,
            trailing: dueDate == null
                ? null
                : IconButton(
                    tooltip: 'Clear due date',
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      onClearDueDate();
                    },
                    icon: const Icon(AppIcons.close),
                  ),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: useDueTime,
            onChanged: dueDate == null
                ? null
                : (value) {
                    HapticFeedback.selectionClick();
                    onUseDueTimeChanged(value);
                  },
            title: const Text('Use due time'),
            subtitle: Text(
              dueDate == null
                  ? 'Select a due date first.'
                  : 'Adds an exact time to this one-time task.',
            ),
          ),
          if (useDueTime)
            AppPickerTile(
              label: 'Due time',
              icon: AppIcons.time,
              value: dueTime == null ? 'Pick time' : dueTime!.format(context),
              onTap: onPickDueTime,
            ),
        ],
      ),
    );
  }

  String? get _subtitle {
    if (recurrenceActive) {
      return 'Selecting a due date will turn recurrence off.';
    }

    if (taskMode == TaskMode.urgent && (dueDate == null || !useDueTime)) {
      return 'Urgent tasks work best with a date and time.';
    }

    return 'Use this for one-time deadlines or planned tasks.';
  }
}
