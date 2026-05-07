import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/loading_status.dart';
import '../../../core/error/error_mapper.dart';
import '../domain/repository/stay_session_repository.dart';
import 'stay_session_state.dart';

class StaySessionNotifier extends StateNotifier<StaySessionState> {
  final StaySessionRepository repository;

  StaySessionNotifier(this.repository) : super(StaySessionState.initial());

  Future<void> load({required String userId, required DateTime date}) async {
    state = state.copyWith(
      status: LoadingStatus.loading,
      selectedDate: date,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final items = await repository.getByUserAndDay(
        userId: userId,
        date: date,
      );

      items.sort((a, b) => a.startTime.compareTo(b.startTime));

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

  Future<void> rebuild({required String userId, required DateTime date}) async {
    state = state.copyWith(
      status: LoadingStatus.saving,
      selectedDate: date,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final message = await repository.rebuild(userId: userId, date: date);
      final items = await repository.getByUserAndDay(
        userId: userId,
        date: date,
      );
      items.sort((a, b) => a.startTime.compareTo(b.startTime));

      state = state.copyWith(
        status: LoadingStatus.success,
        items: items,
        successMessage: message.isEmpty ? 'Stay sessions rebuilt' : message,
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
      await repository.deleteByUserAndDay(userId: userId, date: date);

      state = state.copyWith(
        status: LoadingStatus.success,
        items: const [],
        successMessage: 'Stay sessions deleted',
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
