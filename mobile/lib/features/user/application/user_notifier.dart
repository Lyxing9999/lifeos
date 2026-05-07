import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/loading_status.dart';
import '../../../core/error/error_mapper.dart';
import '../domain/repository/user_repository.dart';
import 'user_state.dart';

class UserNotifier extends StateNotifier<UserState> {
  final UserRepository repository;

  UserNotifier(this.repository) : super(UserState.initial());

  Future<void> loadProfile() async {
    state = state.copyWith(
      status: LoadingStatus.loading,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final profile = await repository.getProfile();
      state = state.copyWith(
        status: LoadingStatus.success,
        profile: profile,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        profile: null,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String timezone,
    required String locale,
  }) async {
    state = state.copyWith(
      status: LoadingStatus.saving,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final updated = await repository.updateProfile(
        name: name,
        timezone: timezone,
        locale: locale,
      );

      state = state.copyWith(
        status: LoadingStatus.success,
        profile: updated,
        successMessage: 'Profile updated successfully',
      );

      return true;
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}
