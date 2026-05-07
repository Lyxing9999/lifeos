import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../../app/theme/app_icons.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/widgets/app_chip.dart';
import '../../../../../core/widgets/app_form_section.dart';
import '../../../../../core/widgets/app_picker_tile.dart';
import '../../../content/task_copy.dart';
import '../../../domain/enum/task_recurrence_type.dart';
import 'task_form_constants.dart';

class TaskRecurrenceSection extends StatelessWidget {
  final bool showRecurrence;
  final TaskRecurrenceType recurrenceType;
  final DateTime? recurrenceStartDate;
  final DateTime? recurrenceEndDate;
  final Set<String> recurrenceDaysOfWeek;

  final ValueChanged<bool> onToggleRecurrence;
  final ValueChanged<TaskRecurrenceType> onSelectRecurrenceType;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickEndDate;
  final ValueChanged<String> onToggleWeekday;

  const TaskRecurrenceSection({
    super.key,
    required this.showRecurrence,
    required this.recurrenceType,
    required this.recurrenceStartDate,
    required this.recurrenceEndDate,
    required this.recurrenceDaysOfWeek,
    required this.onToggleRecurrence,
    required this.onSelectRecurrenceType,
    required this.onPickStartDate,
    required this.onPickEndDate,
    required this.onToggleWeekday,
  });

  @override
  Widget build(BuildContext context) {
    final recurrenceVisible = showRecurrence && recurrenceType.isRecurring;

    return AppFormSection(
      title: TaskCopy.formSectionRepeat,
      subtitle:
          'Repeat controls whether this task appears again on future days.',
      child: Column(
        children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: showRecurrence,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              onToggleRecurrence(value);
            },
            title: const Text('Repeat task'),
            subtitle: Text(
              showRecurrence
                  ? 'Starts ${DateFormat.yMMMd().format(recurrenceStartDate ?? DateTime.now())}'
                  : 'Off — this task does not repeat.',
            ),
          ),
          if (showRecurrence) ...[
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: TaskRecurrenceType.values
                  .where((type) => type != TaskRecurrenceType.none)
                  .map(
                    (type) => AppChip.filter(
                      label: type.label,
                      selected: recurrenceType == type,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onSelectRecurrenceType(type);
                      },
                    ),
                  )
                  .toList(),
            ),
            if (recurrenceVisible) ...[
              const SizedBox(height: AppSpacing.sm),
              AppPickerTile(
                label: 'Starts',
                icon: AppIcons.start,
                value: recurrenceStartDate == null
                    ? 'Today'
                    : DateFormat.yMMMd().format(recurrenceStartDate!),
                onTap: onPickStartDate,
              ),
              AppPickerTile(
                label: 'Ends',
                icon: AppIcons.stop,
                value: recurrenceEndDate == null
                    ? 'Never'
                    : DateFormat.yMMMd().format(recurrenceEndDate!),
                onTap: onPickEndDate,
              ),
            ],
            if (recurrenceType == TaskRecurrenceType.customWeekly)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: taskWeekdayOptions.map((day) {
                    final selected = recurrenceDaysOfWeek.contains(day);

                    return FilterChip(
                      label: Text(taskWeekdayLabel(day)),
                      selected: selected,
                      onSelected: (_) {
                        HapticFeedback.selectionClick();
                        onToggleWeekday(day);
                      },
                    );
                  }).toList(),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
