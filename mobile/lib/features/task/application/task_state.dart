import '../../../core/enums/loading_status.dart';
import '../domain/entities/task.dart';
import '../domain/entities/task_overview.dart';
import '../domain/entities/task_surface.dart';
import '../domain/enum/task_filter.dart';

class TaskState {
  final LoadingStatus status;
  final LoadingStatus mutationStatus;

  final List<Task> tasks;
  final Task? selectedTask;
  final TaskOverview? overview;
  final TaskSurfaceOverview? surfaces;

  final DateTime selectedDate;
  final TaskFilter selectedFilter;

  final String? errorMessage;
  final String? successMessage;

  const TaskState({
    required this.status,
    required this.mutationStatus,
    required this.tasks,
    required this.selectedTask,
    required this.overview,
    required this.surfaces,
    required this.selectedDate,
    required this.selectedFilter,
    required this.errorMessage,
    required this.successMessage,
  });

  factory TaskState.initial() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return TaskState(
      status: LoadingStatus.idle,
      mutationStatus: LoadingStatus.idle,
      tasks: const [],
      selectedTask: null,
      overview: null,
      surfaces: null,
      selectedDate: today,
      selectedFilter: TaskFilter.due,
      errorMessage: null,
      successMessage: null,
    );
  }

  bool get isLoading => status.isLoading;

  bool get isSaving => mutationStatus.isSaving;

  bool get hasError => status.isError || mutationStatus.isError;

  TaskState copyWith({
    LoadingStatus? status,
    LoadingStatus? mutationStatus,
    List<Task>? tasks,
    Task? selectedTask,
    bool clearSelectedTask = false,
    TaskOverview? overview,
    bool clearOverview = false,
    TaskSurfaceOverview? surfaces,
    bool clearSurfaces = false,
    DateTime? selectedDate,
    TaskFilter? selectedFilter,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return TaskState(
      status: status ?? this.status,
      mutationStatus: mutationStatus ?? this.mutationStatus,
      tasks: tasks ?? this.tasks,
      selectedTask: clearSelectedTask
          ? null
          : selectedTask ?? this.selectedTask,
      overview: clearOverview ? null : overview ?? this.overview,
      surfaces: clearSurfaces ? null : surfaces ?? this.surfaces,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      successMessage: clearSuccessMessage
          ? null
          : successMessage ?? this.successMessage,
    );
  }
}
