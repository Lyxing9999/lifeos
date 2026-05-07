import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/loading_status.dart';
import '../../../core/error/error_mapper.dart';
import '../content/schedule_copy.dart';
import '../domain/command/create_schedule_block_command.dart';
import '../domain/command/update_schedule_block_command.dart';
import '../domain/enum/schedule_block_type.dart'; // FIXED: Added missing import
import '../domain/enum/schedule_recurrence_type.dart'; // FIXED: Added missing import
import '../domain/enum/schedule_filter.dart';
import '../domain/repository/schedule_repository.dart';
import 'schedule_state.dart';
import '../domain/enum/schedule_view_filter.dart'; // FIXED: Added missing import

class ScheduleNotifier extends StateNotifier<ScheduleState> {
  final ScheduleRepository repository;

  ScheduleNotifier(this.repository) : super(ScheduleState.initial());
  void setFilter(ScheduleFilter filter) =>
      state = state.copyWith(selectedFilter: filter);
  void setViewFilter(ScheduleViewFilter filter) =>
      state = state.copyWith(viewFilter: filter);

  Future<void> loadSurfaces({
    required DateTime date,
    bool isRefresh = false,
  }) async {
    state = state.copyWith(
      status: isRefresh ? state.status : LoadingStatus.loading,
      clearErrorMessage: true,
    );

    try {
      final surfaces = await repository.getSurfaces(date: date);
      state = state.copyWith(status: LoadingStatus.success, surfaces: surfaces);
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> loadById({required String id}) async {
    state = state.copyWith(
      status: LoadingStatus.loading,
      clearErrorMessage: true,
    );
    try {
      final block = await repository.getScheduleBlockById(id: id);
      if (block == null) throw StateError(ScheduleCopy.errorNotFound);
      state = state.copyWith(
        status: LoadingStatus.success,
        selectedItem: block,
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
        selectedItem: null,
      );
    }
  }

  Future<void> create(CreateScheduleBlockCommand command) async {
    state = state.copyWith(
      mutationStatus: LoadingStatus.saving,
      clearErrorMessage: true,
    );
    try {
      await repository.createScheduleBlock(
        title: command.title,
        type: command.type,
        description: command.description,
        recurrenceType: command.recurrenceType,
        startTime: command.startTime,
        endTime: command.endTime,
        daysOfWeek: command.recurrenceDaysOfWeek,
        recurrenceStartDate: command.recurrenceStartDate,
        recurrenceEndDate: command.recurrenceEndDate,
      );
      state = state.copyWith(
        mutationStatus: LoadingStatus.success,
        successMessage: ScheduleCopy.successCreated,
      );
    } catch (error) {
      state = state.copyWith(
        mutationStatus: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
      rethrow;
    }
  }

  Future<void> updateBlock({
    required String id,
    required UpdateScheduleBlockCommand command,
  }) async {
    state = state.copyWith(
      mutationStatus: LoadingStatus.saving,
      clearErrorMessage: true,
    );
    try {
      final updated = await repository.updateScheduleBlock(
        id: id,
        title: command.title ?? '',
        type: command.type ?? ScheduleBlockType.other,
        description: command.description,
        recurrenceType: command.recurrenceType ?? ScheduleRecurrenceType.none,
        startTime: command.startTime ?? const TimeOfDay(hour: 0, minute: 0),
        endTime: command.endTime ?? const TimeOfDay(hour: 0, minute: 0),
        daysOfWeek: command.recurrenceDaysOfWeek ?? const [],
        recurrenceStartDate: command.recurrenceStartDate ?? DateTime.now(),
        recurrenceEndDate: command.recurrenceEndDate,
        active: command.active,
      );
      state = state.copyWith(
        mutationStatus: LoadingStatus.success,
        selectedItem: updated,
        successMessage: ScheduleCopy.successUpdated,
      );
    } catch (error) {
      state = state.copyWith(
        mutationStatus: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
      rethrow;
    }
  }

  Future<void> deactivateSchedule({required String scheduleId}) async {
    state = state.copyWith(
      mutationStatus: LoadingStatus.saving,
      clearErrorMessage: true,
    );
    try {
      await repository.deactivateScheduleBlock(scheduleId);
      state = state.copyWith(
        mutationStatus: LoadingStatus.success,
        successMessage: ScheduleCopy.successDeactivated,
      );
    } catch (error) {
      state = state.copyWith(
        mutationStatus: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
      rethrow;
    }
  }

  Future<void> activateSchedule({required String scheduleId}) async {
    state = state.copyWith(
      mutationStatus: LoadingStatus.saving,
      clearErrorMessage: true,
    );
    try {
      await repository.activateScheduleBlock(scheduleId);
      state = state.copyWith(
        mutationStatus: LoadingStatus.success,
        successMessage: ScheduleCopy.successActivated,
      );
    } catch (error) {
      state = state.copyWith(
        mutationStatus: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
      rethrow;
    }
  }

  Future<void> deleteSchedule({required String scheduleId}) async {
    state = state.copyWith(
      mutationStatus: LoadingStatus.saving,
      clearErrorMessage: true,
    );
    try {
      await repository.deleteScheduleBlock(scheduleId);
      state = state.copyWith(
        mutationStatus: LoadingStatus.success,
        successMessage: ScheduleCopy.successDeleted,
      );
    } catch (error) {
      state = state.copyWith(
        mutationStatus: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
      rethrow;
    }
  }
}
