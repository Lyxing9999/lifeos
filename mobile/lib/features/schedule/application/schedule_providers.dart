import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../data/datasource/schedule_remote_datasource.dart';
import '../data/mapper/schedule_mapper.dart';
import '../data/repository/schedule_repository_impl.dart';
import '../domain/entities/schedule_select_option.dart';
import '../domain/repository/schedule_repository.dart';
import 'schedule_mutation_coordinator.dart'; // NEW IMPORT
import 'schedule_notifier.dart';
import 'schedule_state.dart';
import '../../../core/time/api_date_formatter.dart';

final scheduleRemoteDataSourceProvider = Provider<ScheduleRemoteDataSource>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  final dateFormatter = ref.watch(apiDateFormatterProvider);
  return ScheduleRemoteDataSource(apiClient, dateFormatter);
});

final scheduleMapperProvider = Provider<ScheduleMapper>((ref) {
  return const ScheduleMapper();
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final ds = ref.watch(scheduleRemoteDataSourceProvider);
  final mapper = ref.watch(scheduleMapperProvider);

  return ScheduleRepositoryImpl(remoteDataSource: ds, mapper: mapper);
});

final scheduleSelectOptionsProvider =
    FutureProvider.autoDispose<List<ScheduleSelectOption>>((ref) {
      final repository = ref.watch(scheduleRepositoryProvider);
      return repository.getSelectOptions();
    });

final scheduleNotifierProvider =
    StateNotifierProvider<ScheduleNotifier, ScheduleState>((ref) {
      final repo = ref.watch(scheduleRepositoryProvider);
      return ScheduleNotifier(repo);
    });

// NEW: Exposes the Coordinator to the UI for mutations
final scheduleMutationCoordinatorProvider =
    Provider<ScheduleMutationCoordinator>((ref) {
      return ScheduleMutationCoordinator(ref);
    });
