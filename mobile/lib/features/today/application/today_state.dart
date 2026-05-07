import '../../../core/enums/loading_status.dart';
import '../domain/model/today_overview.dart';

const _unset = Object();

class TodayState {
  final LoadingStatus status;
  final TodayOverview? data;
  final String? errorMessage;
  final DateTime selectedDate;

  const TodayState({
    required this.status,
    required this.data,
    required this.errorMessage,
    required this.selectedDate,
  });

  bool get isIdle => status.isIdle;
  bool get isLoading => status.isLoading;
  bool get isSaving => status.isSaving;
  bool get isSuccess => status.isSuccess;
  bool get isError => status.isError;

  factory TodayState.initial() {
    return TodayState(
      status: LoadingStatus.idle,
      data: null,
      errorMessage: null,
      selectedDate: DateTime.now(),
    );
  }

  TodayState copyWith({
    LoadingStatus? status,
    Object? data = _unset,
    Object? errorMessage = _unset,
    DateTime? selectedDate,
  }) {
    return TodayState(
      status: status ?? this.status,
      data: identical(data, _unset) ? this.data : data as TodayOverview?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}
