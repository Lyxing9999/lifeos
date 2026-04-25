import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/loading_status.dart';
import '../../../core/error/error_mapper.dart';
import '../domain/repository/score_repository.dart';
import 'score_state.dart';

class ScoreNotifier extends StateNotifier<ScoreState> {
  final ScoreRepository repository;

  ScoreNotifier(this.repository) : super(ScoreState.initial());

  Future<void> load({required String userId, required DateTime date}) async {
    state = state.copyWith(
      status: LoadingStatus.loading,
      selectedDate: date,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final score = await repository.getDailyScore(userId: userId, date: date);

      state = state.copyWith(
        status: LoadingStatus.success,
        score: score,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        score: null,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> generate({
    required String userId,
    required DateTime date,
  }) async {
    state = state.copyWith(
      status: LoadingStatus.saving,
      selectedDate: date,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final score = await repository.generateDailyScore(
        userId: userId,
        date: date,
      );

      state = state.copyWith(
        status: LoadingStatus.success,
        score: score,
        successMessage: 'Daily score generated',
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> delete({required String userId, required DateTime date}) async {
    state = state.copyWith(
      status: LoadingStatus.saving,
      errorMessage: null,
      successMessage: null,
    );

    try {
      await repository.deleteDailyScore(userId: userId, date: date);

      state = state.copyWith(
        status: LoadingStatus.success,
        score: null,
        successMessage: 'Daily score deleted',
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> changeDay({
    required String userId,
    required DateTime date,
  }) async {
    await load(userId: userId, date: date);
  }
}
