import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../data/datasource/location_remote_datasource.dart';
import '../data/mapper/location_mapper.dart';
import '../data/repository/location_repository_impl.dart';
import '../domain/repository/location_repository.dart';
import 'location_notifier.dart';
import 'location_state.dart';

final locationRemoteDataSourceProvider = Provider<LocationRemoteDataSource>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return LocationRemoteDataSource(apiClient);
});

final locationMapperProvider = Provider<LocationMapper>((ref) {
  return const LocationMapper();
});

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  final ds = ref.watch(locationRemoteDataSourceProvider);
  final mapper = ref.watch(locationMapperProvider);

  return LocationRepositoryImpl(remoteDataSource: ds, mapper: mapper);
});

final locationNotifierProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
      final repo = ref.watch(locationRepositoryProvider);
      return LocationNotifier(repo);
    });
