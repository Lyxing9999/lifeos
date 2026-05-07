import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../data/datasource/timeline_remote_datasource.dart';
import '../data/mapper/timeline_mapper.dart';
import '../data/repository/timeline_repository_impl.dart';
import '../domain/repository/timeline_repository.dart';
import 'timeline_notifier.dart';
import 'timeline_state.dart';

final timelineRemoteDataSourceProvider = Provider<TimelineRemoteDataSource>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return TimelineRemoteDataSource(apiClient);
});

final timelineMapperProvider = Provider<TimelineMapper>((ref) {
  return const TimelineMapper();
});

final timelineRepositoryProvider = Provider<TimelineRepository>((ref) {
  final ds = ref.watch(timelineRemoteDataSourceProvider);
  final mapper = ref.watch(timelineMapperProvider);

  return TimelineRepositoryImpl(remoteDataSource: ds, mapper: mapper);
});

final timelineNotifierProvider =
    StateNotifierProvider<TimelineNotifier, TimelineState>((ref) {
      final repo = ref.watch(timelineRepositoryProvider);
      return TimelineNotifier(repo);
    });
