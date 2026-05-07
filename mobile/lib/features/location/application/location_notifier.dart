import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/loading_status.dart';
import '../../../core/error/error_mapper.dart';
import '../domain/repository/location_repository.dart';
import 'location_state.dart';

class LocationNotifier extends StateNotifier<LocationState> {
  final LocationRepository repository;

  LocationNotifier(this.repository) : super(LocationState.initial());

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
      final logs = await repository.getByUserAndDay(userId: userId, date: date);

      logs.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

      state = state.copyWith(
        status: LoadingStatus.success,
        logs: logs,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        logs: const [],
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<bool> addSingle({
    required String userId,
    required double latitude,
    required double longitude,
    double? accuracyMeters,
    double? speedMetersPerSecond,
    String? source,
    required DateTime recordedAt,
  }) async {
    return addBatch(
      userId: userId,
      logs: [
        LocationLogCreateInput(
          latitude: latitude,
          longitude: longitude,
          accuracyMeters: accuracyMeters,
          speedMetersPerSecond: speedMetersPerSecond,
          source: source,
          recordedAt: recordedAt,
        ),
      ],
      successLabel: 'Location point uploaded',
    );
  }

  Future<bool> addDemoBatch({required String userId}) async {
    final now = DateTime.now();
    return addBatch(
      userId: userId,
      logs: [
        LocationLogCreateInput(
          latitude: 11.5564,
          longitude: 104.9282,
          accuracyMeters: 8,
          speedMetersPerSecond: 0,
          source: 'MOBILE_GPS',
          recordedAt: now.subtract(const Duration(hours: 2)),
        ),
        LocationLogCreateInput(
          latitude: 11.5570,
          longitude: 104.9290,
          accuracyMeters: 10,
          speedMetersPerSecond: 0,
          source: 'MOBILE_GPS',
          recordedAt: now.subtract(const Duration(hours: 1, minutes: 30)),
        ),
        LocationLogCreateInput(
          latitude: 11.5600,
          longitude: 104.9305,
          accuracyMeters: 12,
          speedMetersPerSecond: 0,
          source: 'MOBILE_GPS',
          recordedAt: now.subtract(const Duration(hours: 1)),
        ),
      ],
      successLabel: 'Location batch uploaded',
    );
  }

  Future<bool> addBatch({
    required String userId,
    required List<LocationLogCreateInput> logs,
    required String successLabel,
  }) async {
    state = state.copyWith(
      status: LoadingStatus.saving,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final result = await repository.createBatch(userId: userId, logs: logs);

      state = state.copyWith(
        status: LoadingStatus.success,
        successMessage:
            '$successLabel (${result.acceptedPoints}/${result.requestedPoints})',
      );

      await loadByDay(userId: userId, date: state.selectedDate);
      return true;
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
      return false;
    }
  }

  Future<void> changeDay({
    required String userId,
    required DateTime date,
  }) async {
    await loadByDay(userId: userId, date: date);
  }
}
