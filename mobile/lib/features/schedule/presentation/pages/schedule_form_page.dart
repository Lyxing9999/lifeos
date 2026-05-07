import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/app_form_section.dart';
import '../../../../core/widgets/app_form_widget.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/app_picker_tile.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../content/schedule_copy.dart';
import '../../domain/enum/schedule_block_type.dart';
import '../../domain/enum/schedule_recurrence_type.dart';
import '../../domain/entities/schedule_block.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ScheduleFormPage — Senior-level form using AppFormMixin
//
// Principles applied:
//   1. Form key + inline validation (TextFormField via AppTextFormField)
//   2. Keyboard focus chaining (title → description → done)
//   3. Chip pickers for type/recurrence (zero typing)
//   4. Date formatting via intl (AppFormMixin.formatDate)
//   5. Cross-field validation (end > start) via showFormError
//   6. Duration label computed live
//   7. Safe async submit via AppFormMixin.submitForm
//   8. Accessibility: 48dp day buttons with Semantics
// ─────────────────────────────────────────────────────────────────────────────

class ScheduleFormPage extends StatefulWidget {
  final ScheduleBlock? existing;
  final Future<void> Function(ScheduleFormResult result) onSubmit;
  final bool isSaving;
  final bool shouldPopOnSubmit;

  const ScheduleFormPage({
    super.key,
    this.existing,
    required this.onSubmit,
    required this.isSaving,
    this.shouldPopOnSubmit = true,
  });

  @override
  State<ScheduleFormPage> createState() => _ScheduleFormPageState();
}

class _ScheduleFormPageState extends State<ScheduleFormPage> with AppFormMixin {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _titleFocus = FocusNode();
  final _descriptionFocus = FocusNode();

  late ScheduleBlockType _type;
  late ScheduleRecurrenceType _recurrenceType;
  late DateTime _recurrenceStartDate;
  DateTime? _recurrenceEndDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late Set<int> _daysOfWeek;

  bool get _isEdit => widget.existing != null;
  bool get _needsDays => _recurrenceType == ScheduleRecurrenceType.customWeekly;
  bool get _isOneTime => _recurrenceType == ScheduleRecurrenceType.none;
  bool get _isRecurring => !_isOneTime;

  String get _firstWeekdayLabel {
    if (_daysOfWeek.isNotEmpty) {
      final sortedDays = _daysOfWeek.toList()..sort();
      return _weekdayLabel(sortedDays.first);
    }
    return _weekdayLabel(_recurrenceStartDate.weekday.clamp(1, 7));
  }

  String get _recurrenceHelperText {
    switch (_recurrenceType) {
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

  static const _days = [
    (1, 'Mon'),
    (2, 'Tue'),
    (3, 'Wed'),
    (4, 'Thu'),
    (5, 'Fri'),
    (6, 'Sat'),
    (7, 'Sun'),
  ];

  // ── Lifecycle ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    if (widget.existing != null) {
      final item = widget.existing!;
      _titleController.text = item.title;
      _descriptionController.text = item.description ?? '';
      _type = item.type;
      _recurrenceType = item.recurrenceType;
      _recurrenceStartDate = item.recurrenceStartDate;
      _recurrenceEndDate = item.recurrenceEndDate;
      _startTime = item.startTime;
      _endTime = item.endTime;
      _daysOfWeek = item.recurrenceDaysOfWeek.toSet();
    } else {
      _type = ScheduleBlockType.work;
      _recurrenceType = ScheduleRecurrenceType.none;
      _recurrenceStartDate = DateTime(now.year, now.month, now.day);
      _recurrenceEndDate = null;
      _startTime = const TimeOfDay(hour: 9, minute: 0);
      _endTime = const TimeOfDay(hour: 10, minute: 0);
      _daysOfWeek = {};
    }

    if (_recurrenceType == ScheduleRecurrenceType.weekly &&
        _daysOfWeek.isEmpty) {
      _daysOfWeek = {_recurrenceStartDate.weekday.clamp(1, 7)};
    }

    Future.microtask(() => _titleFocus.requestFocus());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  // ── Computed ───────────────────────────────────────────────────────────

  List<ScheduleRecurrenceType> get _recurrenceOptions {
    return const [
      ScheduleRecurrenceType.none,
      ScheduleRecurrenceType.daily,
      ScheduleRecurrenceType.weekly,
      ScheduleRecurrenceType.customWeekly,
      ScheduleRecurrenceType.monthly,
    ];
  }

  String get _durationLabel {
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    final minutes = endMinutes - startMinutes;
    if (minutes <= 0) return 'Invalid range';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours == 0) return '${remainingMinutes}m';
    if (remainingMinutes == 0) return '${hours}h';
    return '${hours}h ${remainingMinutes}m';
  }

  // ── Interactions ───────────────────────────────────────────────────────

  void _onRecurrenceChanged(ScheduleRecurrenceType type) {
    final defaultDay = _recurrenceStartDate.weekday.clamp(1, 7);
    setState(() {
      _recurrenceType = type;
      switch (type) {
        case ScheduleRecurrenceType.none:
          _daysOfWeek = {};
          _recurrenceEndDate = null;
          break;
        case ScheduleRecurrenceType.daily:
          _daysOfWeek = {};
          break;
        case ScheduleRecurrenceType.weekly:
          _daysOfWeek = {defaultDay};
          break;
        case ScheduleRecurrenceType.customWeekly:
          _daysOfWeek = _daysOfWeek.isEmpty ? {defaultDay} : _daysOfWeek;
          break;
        case ScheduleRecurrenceType.monthly:
          _daysOfWeek = {};
          break;
      }
    });
  }

  // ── Pickers ────────────────────────────────────────────────────────────

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _recurrenceStartDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      HapticFeedback.selectionClick();
      setState(() {
        _recurrenceStartDate = picked;
        if (_recurrenceType == ScheduleRecurrenceType.weekly) {
          _daysOfWeek = {picked.weekday.clamp(1, 7)};
        }
      });
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _recurrenceEndDate ?? _recurrenceStartDate,
      firstDate: _recurrenceStartDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      HapticFeedback.selectionClick();
      setState(() => _recurrenceEndDate = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      HapticFeedback.selectionClick();
      // Smart: auto-bump end time to maintain the original duration gap.
      final oldStartMins = _startTime.hour * 60 + _startTime.minute;
      final oldEndMins = _endTime.hour * 60 + _endTime.minute;
      final gap = oldEndMins - oldStartMins; // Could be <= 0 if already invalid
      final newStartMins = picked.hour * 60 + picked.minute;

      setState(() {
        _startTime = picked;
        // Only auto-bump if the gap was valid (> 0) and new start >= old end
        if (gap > 0 && newStartMins >= oldEndMins) {
          final newEndMins = (newStartMins + gap).clamp(0, 23 * 60 + 59);
          _endTime = TimeOfDay(hour: newEndMins ~/ 60, minute: newEndMins % 60);
        }
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      HapticFeedback.selectionClick();
      setState(() => _endTime = picked);
    }
  }

  void _toggleDay(int day) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_daysOfWeek.contains(day)) {
        _daysOfWeek.remove(day);
      } else {
        _daysOfWeek.add(day);
      }
    });
  }

  // ── Submit ─────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    // Cross-field validation (not coverable by inline TextFormField validators)
    final startMins = _startTime.hour * 60 + _startTime.minute;
    final endMins = _endTime.hour * 60 + _endTime.minute;

    if (endMins <= startMins) {
      showFormError(ScheduleCopy.errorTimeRange);
      return;
    }

    if (_needsDays && _daysOfWeek.isEmpty) {
      showFormError(ScheduleCopy.errorRecurrenceDays);
      return;
    }

    if (_recurrenceEndDate != null &&
        _recurrenceEndDate!.isBefore(_recurrenceStartDate)) {
      showFormError(ScheduleCopy.errorRecurrenceDateRange);
      return;
    }

    await widget.onSubmit(
      ScheduleFormResult(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        type: _type,
        recurrenceType: _recurrenceType,
        recurrenceStartDate: _recurrenceStartDate,
        recurrenceEndDate: _recurrenceType == ScheduleRecurrenceType.none
            ? null
            : _recurrenceEndDate,
        startTime: _startTime,
        endTime: _endTime,
        daysOfWeek: _daysOfWeek.toList()..sort(),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return buildFormPage(
      title: _isEdit ? ScheduleCopy.formEditTitle : ScheduleCopy.formNewTitle,
      subtitle: _isEdit
          ? ScheduleCopy.formEditSubtitle
          : ScheduleCopy.formNewSubtitle,
      submitLabel: ScheduleCopy.formSubmitCreate,
      editSubmitLabel: ScheduleCopy.formSubmitEdit,
      isSaving: widget.isSaving,
      isEdit: _isEdit,
      onSubmit: _submit,
      shouldPopOnSubmit: widget.shouldPopOnSubmit,
      children: [
        // ── Core ────────────────────────────────────────────────────────
        AppFormSection(
          title: ScheduleCopy.formSectionCore,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextFormField(
                controller: _titleController,
                focusNode: _titleFocus,
                hintText: ScheduleCopy.formTitleHint,
                prefixIcon: AppIcons.schedule,
                textInputAction: TextInputAction.next,
                validator: FormValidators.requiredField('Title'),
                onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: ScheduleBlockType.values.map((type) {
                  final selected = _type == type;
                  return AppChip.filter(
                    label: type.label,
                    selected: selected,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _type = type);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextFormField(
                controller: _descriptionController,
                focusNode: _descriptionFocus,
                hintText: ScheduleCopy.formDescriptionHint,
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        ),

        // ── Time block ──────────────────────────────────────────────────
        AppFormSection(
          title: ScheduleCopy.formSectionTimeBlock,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppPickerTile(
                      label: ScheduleCopy.formStartTime,
                      value: formatTime(context, _startTime),
                      icon: AppIcons.time,
                      onTap: _pickStartTime,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppPickerTile(
                      label: ScheduleCopy.formEndTime,
                      value: formatTime(context, _endTime),
                      icon: AppIcons.time,
                      onTap: _pickEndTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${ScheduleCopy.formDurationPrefix}: $_durationLabel',
                style: AppTextStyles.bodySecondary(context),
              ),
            ],
          ),
        ),

        // ── Recurrence ──────────────────────────────────────────────────
        AppFormSection(
          title: ScheduleCopy.formSectionRecurrence,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _recurrenceOptions.map((type) {
                  final selected = _recurrenceType == type;
                  return AppChip.filter(
                    label: type.label,
                    selected: selected,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _onRecurrenceChanged(type);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _recurrenceHelperText,
                style: AppTextStyles.bodySecondary(context),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppPickerTile(
                label: _isOneTime
                    ? ScheduleCopy.formRecurrenceDate
                    : ScheduleCopy.formRecurrenceStartDate,
                value: formatDate(_recurrenceStartDate),
                icon: AppIcons.calendar,
                onTap: _pickFromDate,
              ),
              if (_isRecurring) ...[
                const SizedBox(height: AppSpacing.sm),
                AppPickerTile(
                  label: ScheduleCopy.formRecurrenceEndDate,
                  value: _recurrenceEndDate != null
                      ? formatDate(_recurrenceEndDate!)
                      : ScheduleCopy.noEndDate,
                  icon: AppIcons.todayActive,
                  onTap: _pickToDate,
                  trailing: _recurrenceEndDate != null
                      ? IconButton(
                          icon: const Icon(AppIcons.close, size: 18),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            setState(() => _recurrenceEndDate = null);
                          },
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
                    final selected = _daysOfWeek.contains(day);
                    return _DayButton(
                      label: label,
                      selected: selected,
                      onTap: () => _toggleDay(day),
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
        ),
      ],
    );
  }

  String _weekdayLabel(int day) {
    switch (day) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'the selected day';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DayButton — 48×48 touch target with Semantics
// ─────────────────────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────
// ScheduleFormResult (unchanged)
// ─────────────────────────────────────────────────────────────────────────────

class ScheduleFormResult {
  final String title;
  final String? description;
  final ScheduleBlockType type;
  final ScheduleRecurrenceType recurrenceType;
  final DateTime recurrenceStartDate;
  final DateTime? recurrenceEndDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<int> daysOfWeek;

  const ScheduleFormResult({
    required this.title,
    required this.description,
    required this.type,
    required this.recurrenceType,
    required this.recurrenceStartDate,
    required this.recurrenceEndDate,
    required this.startTime,
    required this.endTime,
    required this.daysOfWeek,
  });
}
