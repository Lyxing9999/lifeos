import 'package:flutter/material.dart';
import '../../../domain/enum/schedule_block_type.dart';
import '../../../domain/enum/schedule_recurrence_type.dart';

class ScheduleFormController {
  Future<void> Function()? _submit;

  Future<void> submit() async {
    await _submit?.call();
  }

  void bind(Future<void> Function() submit) {
    _submit = submit;
  }

  void unbind(Future<void> Function() submit) {
    if (_submit == submit) _submit = null;
  }
}

class ScheduleFormInput {
  final String title;
  final String? description;
  final ScheduleBlockType type;
  final ScheduleRecurrenceType recurrenceType;
  final DateTime recurrenceStartDate;
  final DateTime? recurrenceEndDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<int> daysOfWeek;

  const ScheduleFormInput({
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
