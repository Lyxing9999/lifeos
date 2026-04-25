import '../../../core/enums/loading_status.dart';
import '../domain/model/schedule_block.dart';
import '../domain/model/schedule_occurrence.dart';

const _unset = Object();

class ScheduleState {
  final LoadingStatus status;
  final List<ScheduleOccurrence> items;
  final ScheduleBlock? selectedItem;
  final String? errorMessage;
  final String? successMessage;
  final DateTime selectedDate;

  const ScheduleState({
    required this.status,
    required this.items,
    required this.selectedItem,
    required this.errorMessage,
    required this.successMessage,
    required this.selectedDate,
  });

  bool get isIdle => status.isIdle;
  bool get isLoading => status.isLoading;
  bool get isSaving => status.isSaving;
  bool get isSuccess => status.isSuccess;
  bool get isError => status.isError;

  factory ScheduleState.initial() {
    return ScheduleState(
      status: LoadingStatus.idle,
      items: const [],
      selectedItem: null,
      errorMessage: null,
      successMessage: null,
      selectedDate: DateTime.now(),
    );
  }

  ScheduleState copyWith({
    LoadingStatus? status,
    List<ScheduleOccurrence>? items,
    Object? selectedItem = _unset,
    Object? errorMessage = _unset,
    Object? successMessage = _unset,
    DateTime? selectedDate,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      items: items ?? this.items,
      selectedItem: identical(selectedItem, _unset)
          ? this.selectedItem
          : selectedItem as ScheduleBlock?,
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
