import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../data/datasource/task_remote_datasource.dart';
import '../data/mapper/task_mapper.dart';
import '../data/repository/task_repository_impl.dart';
import '../domain/repository/task_repository.dart';
import 'task_notifier.dart';
import 'task_state.dart';

final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TaskRemoteDataSource(apiClient);
});

final taskMapperProvider = Provider<TaskMapper>((ref) {
  return const TaskMapper();
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final ds = ref.watch(taskRemoteDataSourceProvider);
  final mapper = ref.watch(taskMapperProvider);

  return TaskRepositoryImpl(remoteDataSource: ds, mapper: mapper);
});

final taskNotifierProvider = StateNotifierProvider<TaskNotifier, TaskState>((
  ref,
) {
  final repo = ref.watch(taskRepositoryProvider);
  return TaskNotifier(repo);
});
