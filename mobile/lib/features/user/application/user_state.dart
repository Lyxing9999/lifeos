import '../../../core/enums/loading_status.dart';
import '../domain/model/user.dart';

const _unset = Object();

class UserState {
  final LoadingStatus status;
  final AppUser? profile;
  final String? errorMessage;
  final String? successMessage;

  const UserState({
    required this.status,
    required this.profile,
    required this.errorMessage,
    required this.successMessage,
  });

  bool get isIdle => status.isIdle;
  bool get isLoading => status.isLoading;
  bool get isSaving => status.isSaving;
  bool get isSuccess => status.isSuccess;
  bool get isError => status.isError;

  factory UserState.initial() {
    return const UserState(
      status: LoadingStatus.idle,
      profile: null,
      errorMessage: null,
      successMessage: null,
    );
  }

  UserState copyWith({
    LoadingStatus? status,
    Object? profile = _unset,
    Object? errorMessage = _unset,
    Object? successMessage = _unset,
  }) {
    return UserState(
      status: status ?? this.status,
      profile: identical(profile, _unset) ? this.profile : profile as AppUser?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      successMessage: identical(successMessage, _unset)
          ? this.successMessage
          : successMessage as String?,
    );
  }
}
