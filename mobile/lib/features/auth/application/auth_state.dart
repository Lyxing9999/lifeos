import '../../../core/enums/loading_status.dart';

const _unset = Object();

class AuthState {
  final LoadingStatus status;
  final String? userId;
  final String? errorMessage;
  final bool isReady;

  const AuthState({
    required this.status,
    required this.userId,
    required this.errorMessage,
    required this.isReady,
  });

  bool get isIdle => status.isIdle;
  bool get isLoading => status.isLoading;
  bool get isSaving => status.isSaving;
  bool get isSuccess => status.isSuccess;
  bool get isError => status.isError;

  factory AuthState.initial() {
    return const AuthState(
      status: LoadingStatus.idle,
      userId: null,
      errorMessage: null,
      isReady: false,
    );
  }

  AuthState copyWith({
    LoadingStatus? status,
    Object? userId = _unset,
    Object? errorMessage = _unset,
    bool? isReady,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: identical(userId, _unset) ? this.userId : userId as String?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      isReady: isReady ?? this.isReady,
    );
  }
}
