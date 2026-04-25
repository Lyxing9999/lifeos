import '../../../core/enums/loading_status.dart';
import '../domain/model/daily_summary.dart';

const _unset = Object();

class SummaryState {
  final LoadingStatus status;
  final DailySummary? summary;
  final String? errorMessage;
  final String? successMessage;
  final DateTime selectedDate;

  const SummaryState({
    required this.status,
    required this.summary,
    required this.errorMessage,
    required this.successMessage,
    required this.selectedDate,
  });

  bool get isIdle => status.isIdle;
  bool get isLoading => status.isLoading;
  bool get isSaving => status.isSaving;
  bool get isSuccess => status.isSuccess;
  bool get isError => status.isError;

  factory SummaryState.initial() {
    return SummaryState(
      status: LoadingStatus.idle,
      summary: null,
      errorMessage: null,
      successMessage: null,
      selectedDate: DateTime.now(),
    );
  }

  SummaryState copyWith({
    LoadingStatus? status,
    Object? summary = _unset,
    Object? errorMessage = _unset,
    Object? successMessage = _unset,
    DateTime? selectedDate,
  }) {
    return SummaryState(
      status: status ?? this.status,
      summary: identical(summary, _unset)
          ? this.summary
          : summary as DailySummary?,
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
