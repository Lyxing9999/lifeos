import 'package:flutter/material.dart';

import '../enum/schedule_block_type.dart';
import '../enum/schedule_recurrence_type.dart';

class CreateScheduleBlockCommand {
  final String title;
  final ScheduleBlockType type;
  final String? description;

  final TimeOfDay startTime;
  final TimeOfDay endTime;

  final ScheduleRecurrenceType recurrenceType;
  final List<int> recurrenceDaysOfWeek;
  final DateTime recurrenceStartDate;
  final DateTime? recurrenceEndDate;

  const CreateScheduleBlockCommand({
    required this.title,
    this.type = ScheduleBlockType.other,
    this.description,
    required this.startTime,
    required this.endTime,
    this.recurrenceType = ScheduleRecurrenceType.none,
    this.recurrenceDaysOfWeek = const [],
    required this.recurrenceStartDate,
    this.recurrenceEndDate,
  });
}
