import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../data/datasource/user_remote_datasource.dart';
import '../data/mapper/user_mapper.dart';
import '../data/repository/user_repository_impl.dart';
import '../domain/repository/user_repository.dart';
import 'user_notifier.dart';
import 'user_state.dart';

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserRemoteDataSource(apiClient);
});

final userMapperProvider = Provider<UserMapper>((ref) {
  return const UserMapper();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final ds = ref.watch(userRemoteDataSourceProvider);
  final mapper = ref.watch(userMapperProvider);

  return UserRepositoryImpl(remoteDataSource: ds, mapper: mapper);
});

final userNotifierProvider = StateNotifierProvider<UserNotifier, UserState>((
  ref,
) {
  final repository = ref.watch(userRepositoryProvider);
  return UserNotifier(repository);
});
