import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../data/datasource/financial_remote_datasource.dart';
import '../data/mapper/financial_mapper.dart';
import '../data/repository/financial_repository_impl.dart';
import '../domain/repository/financial_repository.dart';
import 'financial_notifier.dart';
import 'financial_state.dart';

final financialRemoteDataSourceProvider = Provider<FinancialRemoteDataSource>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return FinancialRemoteDataSource(apiClient);
});

final financialMapperProvider = Provider<FinancialMapper>((ref) {
  return const FinancialMapper();
});

final financialRepositoryProvider = Provider<FinancialRepository>((ref) {
  final remote = ref.watch(financialRemoteDataSourceProvider);
  final mapper = ref.watch(financialMapperProvider);

  return FinancialRepositoryImpl(remoteDataSource: remote, mapper: mapper);
});

final financialNotifierProvider =
    StateNotifierProvider<FinancialNotifier, FinancialState>((ref) {
      final repository = ref.watch(financialRepositoryProvider);
      return FinancialNotifier(repository);
    });
