import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../data/datasource/summary_remote_datasource.dart';
import '../data/mapper/summary_mapper.dart';
import '../data/repository/summary_repository_impl.dart';
import '../domain/repository/summary_repository.dart';
import 'summary_notifier.dart';
import 'summary_state.dart';

final summaryRemoteDataSourceProvider = Provider<SummaryRemoteDataSource>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return SummaryRemoteDataSource(apiClient);
});

final summaryMapperProvider = Provider<SummaryMapper>((ref) {
  return const SummaryMapper();
});

final summaryRepositoryProvider = Provider<SummaryRepository>((ref) {
  final ds = ref.watch(summaryRemoteDataSourceProvider);
  final mapper = ref.watch(summaryMapperProvider);

  return SummaryRepositoryImpl(remoteDataSource: ds, mapper: mapper);
});

final summaryNotifierProvider =
    StateNotifierProvider<SummaryNotifier, SummaryState>(
      (ref) => SummaryNotifier(ref.watch(summaryRepositoryProvider)),
    );
