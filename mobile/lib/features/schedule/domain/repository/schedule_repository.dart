import 'package:flutter/material.dart';

import '../entities/schedule_block.dart';
import '../entities/schedule_select_option.dart';
import '../entities/schedule_surface.dart';
import '../enum/schedule_block_type.dart';
import '../enum/schedule_recurrence_type.dart';

abstract class ScheduleRepository {
  // ==========================================
  // QUERIES & BFF SURFACES (READ)
  // ==========================================

  /// Replaces the old getScheduleBlocks, getActiveScheduleBlocks, and getOccurrences
  /// by fetching the pre-calculated BFF surface for a specific date.
  Future<ScheduleSurfaceOverview> getSurfaces({required DateTime date});

  Future<List<ScheduleSelectOption>> getSelectOptions();

  Future<ScheduleBlock?> getScheduleBlockById({required String id});

  // ==========================================
  // MUTATIONS (WRITE)
  // ==========================================

  Future<ScheduleBlock> createScheduleBlock({
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

  Future<void> deleteScheduleBlock(String id);

  Future<void> deactivateScheduleBlock(String id);

  Future<void> activateScheduleBlock(String id);
}
