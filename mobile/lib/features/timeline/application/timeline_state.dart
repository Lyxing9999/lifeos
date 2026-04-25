import '../../../core/enums/loading_status.dart';
import '../domain/model/timeline_day.dart';

const _unset = Object();

class TimelineState {
  final LoadingStatus status;
  final TimelineDay? day;
  final String? errorMessage;
  final DateTime selectedDate;

  const TimelineState({
    required this.status,
    required this.day,
    required this.errorMessage,
    required this.selectedDate,
  });

  bool get isIdle => status.isIdle;
  bool get isLoading => status.isLoading;
  bool get isSaving => status.isSaving;
  bool get isSuccess => status.isSuccess;
  bool get isError => status.isError;

  factory TimelineState.initial() {
    return TimelineState(
      status: LoadingStatus.idle,
      day: null,
      errorMessage: null,
      selectedDate: DateTime.now(),
    );
  }

  TimelineState copyWith({
    LoadingStatus? status,
    Object? day = _unset,
    Object? errorMessage = _unset,
    DateTime? selectedDate,
  }) {
    return TimelineState(
      status: status ?? this.status,
      day: identical(day, _unset) ? this.day : day as TimelineDay?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}
