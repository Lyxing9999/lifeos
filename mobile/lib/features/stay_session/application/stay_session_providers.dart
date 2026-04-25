import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../data/datasource/stay_session_remote_datasource.dart';
import '../data/mapper/stay_session_mapper.dart';
import '../data/repository/stay_session_repository_impl.dart';
import '../domain/repository/stay_session_repository.dart';
import 'stay_session_notifier.dart';
import 'stay_session_state.dart';

final staySessionRemoteDataSourceProvider =
    Provider<StaySessionRemoteDataSource>((ref) {
      final apiClient = ref.watch(apiClientProvider);
      return StaySessionRemoteDataSource(apiClient);
    });

final staySessionMapperProvider = Provider<StaySessionMapper>((ref) {
  return const StaySessionMapper();
});

final staySessionRepositoryProvider = Provider<StaySessionRepository>((ref) {
  final ds = ref.watch(staySessionRemoteDataSourceProvider);
  final mapper = ref.watch(staySessionMapperProvider);

  return StaySessionRepositoryImpl(remoteDataSource: ds, mapper: mapper);
});

final staySessionNotifierProvider =
    StateNotifierProvider<StaySessionNotifier, StaySessionState>((ref) {
      final repo = ref.watch(staySessionRepositoryProvider);
      return StaySessionNotifier(repo);
    });
