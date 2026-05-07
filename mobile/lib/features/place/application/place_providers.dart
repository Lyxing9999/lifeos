import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../data/datasource/place_remote_datasource.dart';
import '../data/mapper/place_mapper.dart';
import '../data/repository/place_repository_impl.dart';
import '../domain/repository/place_repository.dart';
import 'place_notifier.dart';
import 'place_state.dart';

final placeRemoteDataSourceProvider = Provider<PlaceRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PlaceRemoteDataSource(apiClient);
});

final placeMapperProvider = Provider<PlaceMapper>((ref) {
  return const PlaceMapper();
});

final placeRepositoryProvider = Provider<PlaceRepository>((ref) {
  final ds = ref.watch(placeRemoteDataSourceProvider);
  final mapper = ref.watch(placeMapperProvider);

  return PlaceRepositoryImpl(remoteDataSource: ds, mapper: mapper);
});

final placeNotifierProvider = StateNotifierProvider<PlaceNotifier, PlaceState>((
  ref,
) {
  final repo = ref.watch(placeRepositoryProvider);
  return PlaceNotifier(repo);
});
