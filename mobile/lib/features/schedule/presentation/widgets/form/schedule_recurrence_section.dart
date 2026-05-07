import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../app/theme/app_icons.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_chip.dart';
import '../../../../../core/widgets/app_form_section.dart';
import '../../../../../core/widgets/app_picker_tile.dart';
import '../../../content/schedule_copy.dart';
import '../../../domain/enum/schedule_recurrence_type.dart';

class ScheduleRecurrenceSection extends StatelessWidget {
  final ScheduleRecurrenceType recurrenceType;
  final DateTime recurrenceStartDate;
  final DateTime? recurrenceEndDate;
  final Set<int> daysOfWeek;

  final ValueChanged<ScheduleRecurrenceType> onRecurrenceChanged;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickEndDate;
  final VoidCallback onClearEndDate;
  final ValueChanged<int> onToggleDay;

  const ScheduleRecurrenceSection({
    super.key,
    required this.recurrenceType,
    required this.recurrenceStartDate,
    required this.recurrenceEndDate,
    required this.daysOfWeek,
    required this.onRecurrenceChanged,
    required this.onPickStartDate,
    required this.onPickEndDate,
    required this.onClearEndDate,
    required this.onToggleDay,
  });

  bool get _isRecurring => recurrenceType != ScheduleRecurrenceType.none;
  bool get _needsDays => recurrenceType == ScheduleRecurrenceType.customWeekly;

  static const _days = [
    (1, 'Mon'),
    (2, 'Tue'),
    (3, 'Wed'),
    (4, 'Thu'),
    (5, 'Fri'),
    (6, 'Sat'),
    (7, 'Sun'),
  ];

  String get _firstWeekdayLabel {
    if (daysOfWeek.isNotEmpty) {
      final sortedDays = daysOfWeek.toList()..sort();
      return _days.firstWhere((e) => e.$1 == sortedDays.first).$2;
    }
    return _days
        .firstWhere((e) => e.$1 == recurrenceStartDate.weekday.clamp(1, 7))
        .$2;
  }

  String get _helperText {
    switch (recurrenceType) {
      case ScheduleRecurrenceType.none:
        return ScheduleCopy.formRecurrenceOnceHelper;
      case ScheduleRecurrenceType.daily:
        return ScheduleCopy.formRecurrenceDailyHelper;
      case ScheduleRecurrenceType.weekly:
        return ScheduleCopy.formRecurrenceWeeklyHelper(_firstWeekdayLabel);
      case ScheduleRecurrenceType.customWeekly:
        return ScheduleCopy.formRecurrenceCustomWeeklyHelper;
      case ScheduleRecurrenceType.monthly:
        return ScheduleCopy.formRecurrenceMonthlyHelper;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppFormSection(
      title: ScheduleCopy.formSectionRecurrence,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: ScheduleRecurrenceType.values.map((type) {
              return AppChip.filter(
                label: type.label,
                selected: recurrenceType == type,
                onTap: () => onRecurrenceChanged(type),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(_helperText, style: AppTextStyles.bodySecondary(context)),
          const SizedBox(height: AppSpacing.sm),
          AppPickerTile(
            label: _isRecurring
                ? ScheduleCopy.formRecurrenceStartDate
                : ScheduleCopy.formRecurrenceDate,
            value: DateFormat.yMMMd().format(recurrenceStartDate),
            icon: AppIcons.calendar,
            onTap: onPickStartDate,
          ),
          if (_isRecurring) ...[
            const SizedBox(height: AppSpacing.sm),
            AppPickerTile(
              label: ScheduleCopy.formRecurrenceEndDate,
              value: recurrenceEndDate != null
                  ? DateFormat.yMMMd().format(recurrenceEndDate!)
                  : ScheduleCopy.noEndDate,
              icon: AppIcons.todayActive,
              onTap: onPickEndDate,
              trailing: recurrenceEndDate != null
                  ? IconButton(
                      icon: const Icon(AppIcons.close, size: 18),
                      onPressed: onClearEndDate,
                    )
                  : null,
            ),
          ],
          if (_needsDays) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _days.map((entry) {
                final (day, label) = entry;
                return _DayButton(
                  label: label,
                  selected: daysOfWeek.contains(day),
                  onTap: () => onToggleDay(day),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              ScheduleCopy.formRecurrenceDaysHelper,
              style: AppTextStyles.bodySecondary(context),
            ),
          ],
        ],
      ),
    );
  }
}

// Re-implemented your custom _DayButton perfectly
class _DayButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DayButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: selected
                      ? color
                      : Theme.of(context).colorScheme.outline,
                  width: selected ? 0 : 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: AppTextStyles.chipLabel(context).copyWith(
                  color: selected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
