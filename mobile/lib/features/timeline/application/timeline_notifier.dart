import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/loading_status.dart';
import '../../../core/error/error_mapper.dart';
import '../domain/repository/timeline_repository.dart';
import 'timeline_state.dart';

class TimelineNotifier extends StateNotifier<TimelineState> {
  final TimelineRepository repository;

  TimelineNotifier(this.repository) : super(TimelineState.initial());

  Future<void> loadDay({required String userId, required DateTime date}) async {
    state = state.copyWith(
      status: LoadingStatus.loading,
      selectedDate: date,
      errorMessage: null,
    );

    try {
      final result = await repository.getDay(userId: userId, date: date);

      state = state.copyWith(
        status: LoadingStatus.success,
        day: result,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        day: null,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> changeDay({
    required String userId,
    required DateTime date,
  }) async {
    await loadDay(userId: userId, date: date);
  }
}
