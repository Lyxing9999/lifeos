import 'package:flutter/material.dart';

import '../enum/schedule_block_type.dart';
import '../enum/schedule_recurrence_type.dart';
import '../model/schedule_block.dart';
import '../model/schedule_occurrence.dart';

abstract class ScheduleRepository {
  Future<List<ScheduleBlock>> getScheduleBlocksByUser(String userId);

  Future<List<ScheduleOccurrence>> getScheduleOccurrencesByUserAndDay({
    required String userId,
    required DateTime date,
  });

  Future<ScheduleBlock?> getScheduleBlockById({
    required String userId,
    required String id,
  });

  Future<ScheduleBlock> createScheduleBlock({
    required String userId,
    required String title,
    required ScheduleBlockType type,
    String? description,
    required ScheduleRecurrenceType recurrenceType,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required List<int> daysOfWeek,
    required DateTime recurrenceStartDate,
    DateTime? recurrenceEndDate,
  });

  Future<ScheduleBlock> updateScheduleBlock({
    required String id,
    required String userId,
    required String title,
    required ScheduleBlockType type,
    String? description,
    required ScheduleRecurrenceType recurrenceType,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required List<int> daysOfWeek,
    required DateTime recurrenceStartDate,
    DateTime? recurrenceEndDate,
    bool? active,
  });

  Future<void> deactivateScheduleBlock(String id);

  Future<void> deleteScheduleBlock(String id);
}
