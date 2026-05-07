import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/loading_status.dart';
import '../../../core/error/error_mapper.dart';
import '../domain/repository/today_repository.dart';
import 'today_state.dart';

class TodayNotifier extends StateNotifier<TodayState> {
  final TodayRepository repository;

  TodayNotifier(this.repository) : super(TodayState.initial());

  Future<void> load({required DateTime date}) async {
    state = state.copyWith(
      status: LoadingStatus.loading,
      selectedDate: date,
      errorMessage: null,
    );

    try {
      final result = await repository.getToday(date: date);
      state = state.copyWith(
        status: LoadingStatus.success,
        data: result,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        data: null,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }
}
