import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../data/datasource/score_remote_datasource.dart';
import '../data/mapper/score_mapper.dart';
import '../data/repository/score_repository_impl.dart';
import '../domain/repository/score_repository.dart';
import 'score_notifier.dart';
import 'score_state.dart';

final scoreRemoteDataSourceProvider = Provider<ScoreRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ScoreRemoteDataSource(apiClient);
});

final scoreMapperProvider = Provider<ScoreMapper>((ref) {
  return const ScoreMapper();
});

final scoreRepositoryProvider = Provider<ScoreRepository>((ref) {
  final ds = ref.watch(scoreRemoteDataSourceProvider);
  final mapper = ref.watch(scoreMapperProvider);

  return ScoreRepositoryImpl(remoteDataSource: ds, mapper: mapper);
});

final scoreNotifierProvider = StateNotifierProvider<ScoreNotifier, ScoreState>((
  ref,
) {
  final repo = ref.watch(scoreRepositoryProvider);
  return ScoreNotifier(repo);
});
