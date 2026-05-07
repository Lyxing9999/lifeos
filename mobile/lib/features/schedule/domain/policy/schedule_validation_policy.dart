import 'package:flutter/material.dart';
import '../enum/schedule_recurrence_type.dart';

class ScheduleValidationPolicy {
  const ScheduleValidationPolicy();

  String? validateForm(
    String title,
    TimeOfDay startTime,
    TimeOfDay endTime,
    ScheduleRecurrenceType type,
    DateTime startDate,
    DateTime? endDate,
    Set<int> daysOfWeek,
  ) {
    if (title.trim().isEmpty) return 'Title is required';

    final startMins = startTime.hour * 60 + startTime.minute;
    final endMins = endTime.hour * 60 + endTime.minute;

    if (endMins <= startMins) {
      return 'End time must be after start time';
    }

    if (type == ScheduleRecurrenceType.customWeekly && daysOfWeek.isEmpty) {
      return 'Choose at least one day for Custom weekly';
    }

    if (endDate != null && endDate.isBefore(startDate)) {
      return 'End date must be on or after start date';
    }

    return null;
  }
}
