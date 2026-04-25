import '../../../core/enums/loading_status.dart';
import '../domain/model/stay_session.dart';

const _unset = Object();

class StaySessionState {
  final LoadingStatus status;
  final List<StaySession> items;
  final String? errorMessage;
  final String? successMessage;
  final DateTime selectedDate;

  const StaySessionState({
    required this.status,
    required this.items,
    required this.errorMessage,
    required this.successMessage,
    required this.selectedDate,
  });

  bool get isIdle => status.isIdle;
  bool get isLoading => status.isLoading;
  bool get isSaving => status.isSaving;
  bool get isSuccess => status.isSuccess;
  bool get isError => status.isError;

  factory StaySessionState.initial() {
    return StaySessionState(
      status: LoadingStatus.idle,
      items: const [],
      errorMessage: null,
      successMessage: null,
      selectedDate: DateTime.now(),
    );
  }

  StaySessionState copyWith({
    LoadingStatus? status,
    List<StaySession>? items,
    Object? errorMessage = _unset,
    Object? successMessage = _unset,
    DateTime? selectedDate,
  }) {
    return StaySessionState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      successMessage: identical(successMessage, _unset)
          ? this.successMessage
          : successMessage as String?,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}
