import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../../core/time/api_date_formatter.dart';
import '../data/datasource/task_remote_datasource.dart';
import '../data/mapper/schedule_select_option_mapper.dart';
import '../data/mapper/task_mapper.dart';
import '../data/repository/task_repository_impl.dart';
import '../domain/entities/schedule_select_option.dart';
import '../domain/repository/task_repository.dart';
import '../domain/policy/task_validation_policy.dart';
import 'task_mutation_coordinator.dart';
import 'task_notifier.dart';
import 'task_state.dart';

final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final dateFormatter = ref.watch(apiDateFormatterProvider);

  return TaskRemoteDataSource(
    apiClient: apiClient,
    dateFormatter: dateFormatter,
  );
});

final taskMapperProvider = Provider<TaskMapper>((ref) {
  return const TaskMapper();
});

final scheduleSelectOptionMapperProvider = Provider<ScheduleSelectOptionMapper>(
  (ref) {
    return const ScheduleSelectOptionMapper();
  },
);

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final remoteDataSource = ref.watch(taskRemoteDataSourceProvider);
  final taskMapper = ref.watch(taskMapperProvider);
  final scheduleSelectOptionMapper = ref.watch(
    scheduleSelectOptionMapperProvider,
  );
  final dateFormatter = ref.watch(apiDateFormatterProvider);

  return TaskRepositoryImpl(
    remoteDataSource: remoteDataSource,
    mapper: taskMapper,
    scheduleSelectOptionMapper: scheduleSelectOptionMapper,
    dateFormatter: dateFormatter,
  );
});

final taskNotifierProvider = StateNotifierProvider<TaskNotifier, TaskState>((
  ref,
) {
  final repository = ref.watch(taskRepositoryProvider);
  const validationPolicy = TaskValidationPolicy();

  return TaskNotifier(repository, validationPolicy);
});

final taskMutationCoordinatorProvider = Provider<TaskMutationCoordinator>((
  ref,
) {
  return TaskMutationCoordinator(ref);
});

final taskScheduleSelectOptionsProvider =
    FutureProvider<List<ScheduleSelectOption>>((ref) async {
      final repository = ref.watch(taskRepositoryProvider);

      return repository.getScheduleSelectOptions();
    });
