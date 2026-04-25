import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/loading_status.dart';
import '../../../core/error/error_mapper.dart';
import '../domain/enum/place_type.dart';
import '../domain/repository/place_repository.dart';
import 'place_state.dart';

class PlaceNotifier extends StateNotifier<PlaceState> {
  final PlaceRepository repository;

  PlaceNotifier(this.repository) : super(PlaceState.initial());

  Future<void> loadPlaces(String userId) async {
    state = state.copyWith(
      status: LoadingStatus.loading,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final items = await repository.getPlacesByUser(userId);
      state = state.copyWith(
        status: LoadingStatus.success,
        items: items,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> loadById(String id) async {
    state = state.copyWith(status: LoadingStatus.loading, errorMessage: null);

    try {
      final item = await repository.getPlaceById(id);
      state = state.copyWith(
        status: LoadingStatus.success,
        selectedItem: item,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        selectedItem: null,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> create({
    required String userId,
    required String name,
    required PlaceType placeType,
    required double latitude,
    required double longitude,
    required double matchRadiusMeters,
  }) async {
    state = state.copyWith(
      status: LoadingStatus.saving,
      errorMessage: null,
      successMessage: null,
    );

    try {
      await repository.createPlace(
        userId: userId,
        name: name,
        placeType: placeType,
        latitude: latitude,
        longitude: longitude,
        matchRadiusMeters: matchRadiusMeters,
      );

      state = state.copyWith(
        status: LoadingStatus.success,
        successMessage: 'Place created',
      );

      await loadPlaces(userId);
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> update({
    required String userId,
    required String id,
    required String name,
    required PlaceType placeType,
    required double latitude,
    required double longitude,
    required double matchRadiusMeters,
    bool? active,
  }) async {
    state = state.copyWith(
      status: LoadingStatus.saving,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final item = await repository.updatePlace(
        id: id,
        name: name,
        placeType: placeType,
        latitude: latitude,
        longitude: longitude,
        matchRadiusMeters: matchRadiusMeters,
        active: active,
      );

      state = state.copyWith(
        status: LoadingStatus.success,
        selectedItem: item,
        successMessage: 'Place updated',
      );

      await loadPlaces(userId);
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> delete({required String userId, required String id}) async {
    state = state.copyWith(
      status: LoadingStatus.saving,
      errorMessage: null,
      successMessage: null,
    );

    try {
      await repository.deletePlace(id);

      state = state.copyWith(
        status: LoadingStatus.success,
        successMessage: 'Place deleted',
        selectedItem: null,
      );

      await loadPlaces(userId);
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }
}
