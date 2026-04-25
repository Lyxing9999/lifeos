import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../score/data/mapper/score_mapper.dart';
import '../../summary/data/mapper/summary_mapper.dart';
import '../../task/data/mapper/task_mapper.dart';
import '../../timeline/data/mapper/timeline_mapper.dart';
import '../data/datasource/today_remote_datasource.dart';
import '../data/mapper/today_mapper.dart';
import '../data/repository/today_repository_impl.dart';
import '../domain/repository/today_repository.dart';
import 'today_notifier.dart';
import 'today_state.dart';

final todayRemoteDataSourceProvider = Provider<TodayRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TodayRemoteDataSource(apiClient);
});

final todayMapperProvider = Provider<TodayMapper>((ref) {
  return TodayMapper(
    summaryMapper: const SummaryMapper(),
    scoreMapper: const ScoreMapper(),
    timelineMapper: const TimelineMapper(),
    taskMapper: const TaskMapper(),
  );
});

final todayRepositoryProvider = Provider<TodayRepository>((ref) {
  final ds = ref.watch(todayRemoteDataSourceProvider);
  final mapper = ref.watch(todayMapperProvider);

  return TodayRepositoryImpl(remoteDataSource: ds, mapper: mapper);
});

final todayNotifierProvider = StateNotifierProvider<TodayNotifier, TodayState>((
  ref,
) {
  final repo = ref.watch(todayRepositoryProvider);
  return TodayNotifier(repo);
});
