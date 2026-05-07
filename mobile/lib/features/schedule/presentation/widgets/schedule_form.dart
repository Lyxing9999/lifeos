import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/schedule_block.dart';
import '../../domain/enum/schedule_block_type.dart';
import '../../domain/enum/schedule_recurrence_type.dart';
import '../../domain/policy/schedule_validation_policy.dart';
import 'form/schedule_core_section.dart';
import 'form/schedule_form_models.dart';
import 'form/schedule_recurrence_section.dart';
import 'form/schedule_time_section.dart';

class ScheduleForm extends StatefulWidget {
  final ScheduleBlock? existing;
  final ScheduleFormController controller;
  final Future<void> Function(ScheduleFormInput result) onSubmit;
  final void Function(String message) onError;

  const ScheduleForm({
    super.key,
    this.existing,
    required this.controller,
    required this.onSubmit,
    required this.onError,
  });

  @override
  State<ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<ScheduleForm> {
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

    widget.controller.bind(_submit);
    Future.microtask(() {
      if (mounted && widget.existing == null) _titleFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    widget.controller.unbind(_submit);
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final error = const ScheduleValidationPolicy().validateForm(
      _titleController.text,
      _startTime,
      _endTime,
      _recurrenceType,
      _recurrenceStartDate,
      _recurrenceEndDate,
      _daysOfWeek,
    );

    if (error != null) {
      widget.onError(error);
      return;
    }

    await widget.onSubmit(
      ScheduleFormInput(
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

  // --- Preserved Smart Time Logic ---
  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      HapticFeedback.selectionClick();
      final oldStartMins = _startTime.hour * 60 + _startTime.minute;
      final oldEndMins = _endTime.hour * 60 + _endTime.minute;
      final gap = oldEndMins - oldStartMins;
      final newStartMins = picked.hour * 60 + picked.minute;

      setState(() {
        _startTime = picked;
        if (gap > 0 && newStartMins >= oldEndMins) {
          final newEndMins = (newStartMins + gap).clamp(0, 23 * 60 + 59);
          _endTime = TimeOfDay(hour: newEndMins ~/ 60, minute: newEndMins % 60);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScheduleCoreSection(
          titleController: _titleController,
          descriptionController: _descriptionController,
          titleFocus: _titleFocus,
          descriptionFocus: _descriptionFocus,
          selectedType: _type,
          onSelectType: (type) {
            HapticFeedback.selectionClick();
            setState(() => _type = type);
          },
        ),
        ScheduleTimeSection(
          startTime: _startTime,
          endTime: _endTime,
          onPickStartTime: _pickStartTime,
          onPickEndTime: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: _endTime,
            );
            if (picked != null) {
              HapticFeedback.selectionClick();
              setState(() => _endTime = picked);
            }
          },
        ),
        ScheduleRecurrenceSection(
          recurrenceType: _recurrenceType,
          recurrenceStartDate: _recurrenceStartDate,
          recurrenceEndDate: _recurrenceEndDate,
          daysOfWeek: _daysOfWeek,
          onRecurrenceChanged: (type) {
            HapticFeedback.selectionClick();
            setState(() {
              _recurrenceType = type;
              final defaultDay = _recurrenceStartDate.weekday.clamp(1, 7);
              if (type == ScheduleRecurrenceType.none ||
                  type == ScheduleRecurrenceType.daily ||
                  type == ScheduleRecurrenceType.monthly) {
                _daysOfWeek.clear();
              } else if (type == ScheduleRecurrenceType.weekly) {
                _daysOfWeek = {defaultDay};
              } else if (type == ScheduleRecurrenceType.customWeekly &&
                  _daysOfWeek.isEmpty) {
                _daysOfWeek = {defaultDay};
              }
              if (type == ScheduleRecurrenceType.none) {
                _recurrenceEndDate = null;
              }
            });
          },
          onPickStartDate: () async {
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
          },
          onPickEndDate: () async {
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
          },
          onClearEndDate: () {
            HapticFeedback.selectionClick();
            setState(() => _recurrenceEndDate = null);
          },
          onToggleDay: (day) {
            HapticFeedback.selectionClick();
            setState(() {
              if (_daysOfWeek.contains(day)) {
                _daysOfWeek.remove(day);
              } else {
                _daysOfWeek.add(day);
              }
            });
          },
        ),
      ],
    );
  }
}
