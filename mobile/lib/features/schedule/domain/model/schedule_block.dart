import 'package:flutter/material.dart';

import '../enum/schedule_block_type.dart';
import '../enum/schedule_recurrence_type.dart';

class ScheduleBlock {
  final String id;
  final String userId;
  final String title;
  final ScheduleBlockType type;
  final String? description;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final ScheduleRecurrenceType recurrenceType;
  final DateTime recurrenceStartDate;
  final DateTime? recurrenceEndDate;
  final List<int> recurrenceDaysOfWeek;
  final bool active;

  const ScheduleBlock({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.recurrenceType,
    required this.recurrenceStartDate,
    required this.recurrenceEndDate,
    required this.recurrenceDaysOfWeek,
    required this.active,
  });
}
