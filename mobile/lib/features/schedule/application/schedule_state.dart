import '../../../core/enums/loading_status.dart';
import '../domain/entities/schedule_block.dart';
import '../domain/entities/schedule_surface.dart';
import '../domain/enum/schedule_filter.dart';
import '../domain/enum/schedule_view_filter.dart';

const _unset = Object();

class ScheduleState {
  final LoadingStatus status;
  final LoadingStatus mutationStatus;

  final ScheduleSurfaceOverview? surfaces;
  final ScheduleFilter selectedFilter; // Active vs Inactive
  final ScheduleViewFilter viewFilter; // All, Work, Study, Personal
  final ScheduleBlock? selectedItem;

  final String? errorMessage;
  final String? successMessage;

  const ScheduleState({
    required this.status,
    required this.mutationStatus,
    required this.surfaces,
    required this.selectedFilter,
    required this.viewFilter,
    required this.selectedItem,
    required this.errorMessage,
    required this.successMessage,
  });

  bool get isLoading => status.isLoading;
  bool get isSaving => mutationStatus.isSaving;

  factory ScheduleState.initial() {
    return const ScheduleState(
      status: LoadingStatus.idle,
      mutationStatus: LoadingStatus.idle,
      surfaces: null,
      selectedFilter: ScheduleFilter.active,
      viewFilter: ScheduleViewFilter.all, // Default to showing all categories
      selectedItem: null,
      errorMessage: null,
      successMessage: null,
    );
  }

  ScheduleState copyWith({
    LoadingStatus? status,
    LoadingStatus? mutationStatus,
    ScheduleSurfaceOverview? surfaces,
    ScheduleFilter? selectedFilter,
    ScheduleViewFilter? viewFilter,
    Object? selectedItem = _unset,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      mutationStatus: mutationStatus ?? this.mutationStatus,
      surfaces: surfaces ?? this.surfaces,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      viewFilter: viewFilter ?? this.viewFilter,
      selectedItem: identical(selectedItem, _unset)
          ? this.selectedItem
          : selectedItem as ScheduleBlock?,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccessMessage
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}
