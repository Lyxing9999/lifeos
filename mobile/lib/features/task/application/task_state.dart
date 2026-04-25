import '../../../core/enums/loading_status.dart';
import '../domain/model/task.dart';
import '../domain/model/task_overview.dart';

const _unset = Object();

class TaskState {
  final LoadingStatus status;
  final List<Task> tasks;
  final TaskOverview? overview;
  final Task? selectedTask;
  final String? selectedFilter;
  final String? errorMessage;
  final String? successMessage;
  final DateTime selectedDate;

  const TaskState({
    required this.status,
    required this.tasks,
    required this.overview,
    required this.selectedTask,
    required this.selectedFilter,
    required this.errorMessage,
    required this.successMessage,
    required this.selectedDate,
  });

  bool get isIdle => status.isIdle;
  bool get isLoading => status.isLoading;
  bool get isSaving => status.isSaving;
  bool get isSuccess => status.isSuccess;
  bool get isError => status.isError;

  factory TaskState.initial() {
    return TaskState(
      status: LoadingStatus.idle,
      tasks: const [],
      overview: null,
      selectedTask: null,
      selectedFilter: 'ACTIVE',
      errorMessage: null,
      successMessage: null,
      selectedDate: DateTime.now(),
    );
  }

  TaskState copyWith({
    LoadingStatus? status,
    List<Task>? tasks,
    Object? overview = _unset,
    Object? selectedTask = _unset,
    Object? selectedFilter = _unset,
    Object? errorMessage = _unset,
    Object? successMessage = _unset,
    DateTime? selectedDate,
  }) {
    return TaskState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      overview: identical(overview, _unset)
          ? this.overview
          : overview as TaskOverview?,
      selectedTask: identical(selectedTask, _unset)
          ? this.selectedTask
          : selectedTask as Task?,
      selectedFilter: identical(selectedFilter, _unset)
          ? this.selectedFilter
          : selectedFilter as String?,
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
