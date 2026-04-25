import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../data/datasource/schedule_remote_datasource.dart';
import '../data/mapper/schedule_mapper.dart';
import '../data/repository/schedule_repository_impl.dart';
import '../domain/repository/schedule_repository.dart';
import 'schedule_notifier.dart';
import 'schedule_state.dart';

final scheduleRemoteDataSourceProvider = Provider<ScheduleRemoteDataSource>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return ScheduleRemoteDataSource(apiClient);
});

final scheduleMapperProvider = Provider<ScheduleMapper>((ref) {
  return const ScheduleMapper();
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final ds = ref.watch(scheduleRemoteDataSourceProvider);
  final mapper = ref.watch(scheduleMapperProvider);

  return ScheduleRepositoryImpl(remoteDataSource: ds, mapper: mapper);
});

final scheduleNotifierProvider =
    StateNotifierProvider<ScheduleNotifier, ScheduleState>((ref) {
      final repo = ref.watch(scheduleRepositoryProvider);
      return ScheduleNotifier(repo);
    });
