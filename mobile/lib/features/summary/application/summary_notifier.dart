import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/loading_status.dart';
import '../../../core/error/error_mapper.dart';
import '../domain/repository/summary_repository.dart';
import 'summary_state.dart';

class SummaryNotifier extends StateNotifier<SummaryState> {
  final SummaryRepository repository;

  SummaryNotifier(this.repository) : super(SummaryState.initial());

  Future<void> load({required DateTime date}) async {
    state = state.copyWith(
      status: LoadingStatus.loading,
      selectedDate: date,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final summary = await repository.getDailySummary(date: date);
      state = state.copyWith(
        status: LoadingStatus.success,
        summary: summary,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        summary: null,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> generate({required DateTime date}) async {
    state = state.copyWith(
      status: LoadingStatus.saving,
      selectedDate: date,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final summary = await repository.generateDailySummary(date: date);
      state = state.copyWith(
        status: LoadingStatus.success,
        summary: summary,
        successMessage: 'Daily summary generated',
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> delete({required DateTime date}) async {
    state = state.copyWith(
      status: LoadingStatus.saving,
      errorMessage: null,
      successMessage: null,
    );

    try {
      await repository.deleteDailySummary(date: date);
      state = state.copyWith(
        status: LoadingStatus.success,
        summary: null,
        successMessage: 'Daily summary deleted',
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> changeDay({required DateTime date}) async {
    await load(date: date);
  }
}
