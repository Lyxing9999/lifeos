import '../../../core/enums/loading_status.dart';
import '../domain/model/daily_score.dart';

const _unset = Object();

class ScoreState {
  final LoadingStatus status;
  final DailyScore? score;
  final String? errorMessage;
  final String? successMessage;
  final DateTime selectedDate;

  const ScoreState({
    required this.status,
    required this.score,
    required this.errorMessage,
    required this.successMessage,
    required this.selectedDate,
  });

  bool get isIdle => status.isIdle;
  bool get isLoading => status.isLoading;
  bool get isSaving => status.isSaving;
  bool get isSuccess => status.isSuccess;
  bool get isError => status.isError;

  factory ScoreState.initial() {
    return ScoreState(
      status: LoadingStatus.idle,
      score: null,
      errorMessage: null,
      successMessage: null,
      selectedDate: DateTime.now(),
    );
  }

  ScoreState copyWith({
    LoadingStatus? status,
    Object? score = _unset,
    Object? errorMessage = _unset,
    Object? successMessage = _unset,
    DateTime? selectedDate,
  }) {
    return ScoreState(
      status: status ?? this.status,
      score: identical(score, _unset) ? this.score : score as DailyScore?,
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
