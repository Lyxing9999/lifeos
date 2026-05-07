import 'package:flutter/material.dart';

import '../enum/schedule_block_type.dart';
import '../enum/schedule_recurrence_type.dart';

class UpdateScheduleBlockCommand {
  final String? title;
  final ScheduleBlockType? type;
  final String? description;

  final TimeOfDay? startTime;
  final TimeOfDay? endTime;

  final ScheduleRecurrenceType? recurrenceType;
  final List<int>? recurrenceDaysOfWeek;
  final DateTime? recurrenceStartDate;
  final DateTime? recurrenceEndDate;

  final bool? active;

  const UpdateScheduleBlockCommand({
    this.title,
    this.type,
    this.description,
    this.startTime,
    this.endTime,
    this.recurrenceType,
    this.recurrenceDaysOfWeek,
    this.recurrenceStartDate,
    this.recurrenceEndDate,
    this.active,
  });
}
