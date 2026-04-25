import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/loading_status.dart';
import '../../../core/error/error_mapper.dart';
import '../content/schedule_copy.dart';
import '../domain/enum/schedule_block_type.dart';
import '../domain/enum/schedule_recurrence_type.dart';
import '../domain/repository/schedule_repository.dart';
import 'schedule_state.dart';

class ScheduleNotifier extends StateNotifier<ScheduleState> {
  final ScheduleRepository repository;

  ScheduleNotifier(this.repository) : super(ScheduleState.initial());

  Future<void> loadByDay({
    required String userId,
    required DateTime date,
  }) async {
    state = state.copyWith(
      status: LoadingStatus.loading,
      selectedDate: date,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final items = await repository.getScheduleOccurrencesByUserAndDay(
        userId: userId,
        date: date,
      );

      state = state.copyWith(
        status: LoadingStatus.success,
        items: items,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        items: const [],
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> changeDay({
    required String userId,
    required DateTime date,
  }) async {
    await loadByDay(userId: userId, date: date);
  }

  Future<void> loadById({required String userId, required String id}) async {
    state = state.copyWith(status: LoadingStatus.loading, errorMessage: null);

    try {
      final block = await repository.getScheduleBlockById(
        userId: userId,
        id: id,
      );
      if (block == null) {
        throw StateError(ScheduleCopy.errorNotFound);
      }
      state = state.copyWith(
        status: LoadingStatus.success,
        selectedItem: block,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        selectedItem: null,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> create({
    required String userId,
    required String title,
    required ScheduleBlockType type,
    required ScheduleRecurrenceType recurrenceType,
    String? description,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required List<int> daysOfWeek,
    required DateTime recurrenceStartDate,
    DateTime? recurrenceEndDate,
  }) async {
    state = state.copyWith(
      status: LoadingStatus.saving,
      errorMessage: null,
      successMessage: null,
    );

    try {
      await repository.createScheduleBlock(
        userId: userId,
        title: title,
        type: type,
        description: description,
        recurrenceType: recurrenceType,
        startTime: startTime,
        endTime: endTime,
        daysOfWeek: daysOfWeek,
        recurrenceStartDate: recurrenceStartDate,
        recurrenceEndDate: recurrenceEndDate,
      );

      state = state.copyWith(
        status: LoadingStatus.success,
        successMessage: ScheduleCopy.successCreated,
      );

      await loadByDay(userId: userId, date: state.selectedDate);
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> update({
    required String userId,
    required String id,
    required String title,
    required ScheduleBlockType type,
    required ScheduleRecurrenceType recurrenceType,
    String? description,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required List<int> daysOfWeek,
    required DateTime recurrenceStartDate,
    DateTime? recurrenceEndDate,
    bool? active,
  }) async {
    state = state.copyWith(
      status: LoadingStatus.saving,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final updated = await repository.updateScheduleBlock(
        id: id,
        userId: userId,
        title: title,
        type: type,
        description: description,
        recurrenceType: recurrenceType,
        startTime: startTime,
        endTime: endTime,
        daysOfWeek: daysOfWeek,
        recurrenceStartDate: recurrenceStartDate,
        recurrenceEndDate: recurrenceEndDate,
        active: active,
      );

      state = state.copyWith(
        status: LoadingStatus.success,
        selectedItem: updated,
        successMessage: ScheduleCopy.successUpdated,
      );

      await loadByDay(userId: userId, date: state.selectedDate);
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> deactivate({required String userId, required String id}) async {
    state = state.copyWith(
      status: LoadingStatus.saving,
      errorMessage: null,
      successMessage: null,
    );

    try {
      await repository.deactivateScheduleBlock(id);

      state = state.copyWith(
        status: LoadingStatus.success,
        selectedItem: null,
        successMessage: ScheduleCopy.successDeactivated,
      );

      await loadByDay(userId: userId, date: state.selectedDate);
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> delete({required String userId, required String id}) async {
    state = state.copyWith(
      status: LoadingStatus.saving,
      errorMessage: null,
      successMessage: null,
    );

    try {
      await repository.deleteScheduleBlock(id);

      state = state.copyWith(
        status: LoadingStatus.success,
        successMessage: ScheduleCopy.successDeleted,
        selectedItem: null,
      );

      await loadByDay(userId: userId, date: state.selectedDate);
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }
}
