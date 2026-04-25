import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/loading_status.dart';
import '../../../core/error/error_mapper.dart';
import '../domain/repository/auth_repository.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;

  AuthNotifier(this.repository) : super(AuthState.initial());

  Future<void> bootstrap() async {
    state = state.copyWith(status: LoadingStatus.loading, errorMessage: null);

    try {
      final session = await repository.bootstrapSession();

      state = state.copyWith(
        status: LoadingStatus.success,
        userId: session.userId,
        errorMessage: null,
        isReady: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        userId: null,
        isReady: false,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> resetSession() async {
    await repository.clearSession();
    await bootstrap();
  }
}
