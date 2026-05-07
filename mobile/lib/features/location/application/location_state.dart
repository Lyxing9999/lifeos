import '../../../core/enums/loading_status.dart';
import '../domain/model/location_log.dart';

const _unset = Object();

class LocationState {
  final LoadingStatus status;
  final List<LocationLog> logs;
  final String? errorMessage;
  final String? successMessage;
  final DateTime selectedDate;

  const LocationState({
    required this.status,
    required this.logs,
    required this.errorMessage,
    required this.successMessage,
    required this.selectedDate,
  });

  bool get isIdle => status.isIdle;
  bool get isLoading => status.isLoading;
  bool get isSaving => status.isSaving;
  bool get isSuccess => status.isSuccess;
  bool get isError => status.isError;

  factory LocationState.initial() {
    return LocationState(
      status: LoadingStatus.idle,
      logs: const [],
      errorMessage: null,
      successMessage: null,
      selectedDate: DateTime.now(),
    );
  }

  LocationState copyWith({
    LoadingStatus? status,
    List<LocationLog>? logs,
    Object? errorMessage = _unset,
    Object? successMessage = _unset,
    DateTime? selectedDate,
  }) {
    return LocationState(
      status: status ?? this.status,
      logs: logs ?? this.logs,
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
