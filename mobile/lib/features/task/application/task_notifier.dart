import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/loading_status.dart';
import '../../../core/error/error_mapper.dart';
import '../content/task_copy.dart';
import '../domain/command/create_task_command.dart';
import '../domain/command/update_task_command.dart';
import '../domain/enum/task_filter.dart';
import '../domain/repository/task_repository.dart';
import '../domain/policy/task_validation_policy.dart';
import 'task_state.dart';

class TaskNotifier extends StateNotifier<TaskState> {
  final TaskRepository repository;
  final TaskValidationPolicy validationPolicy;

  TaskNotifier(this.repository, this.validationPolicy)
    : super(TaskState.initial());
  Future<void> loadSurfaces({
    required DateTime date,
    TaskFilter filter = TaskFilter.due,
    bool isRefresh = false,
  }) async {
    final selectedDay = _localDay(date);

    state = state.copyWith(
      status: isRefresh ? state.status : LoadingStatus.loading,
      selectedDate: selectedDay,
      selectedFilter: filter,
      tasks: const [],
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      final surfaces = await repository.getSurfaces(
        date: selectedDay,
        filter: filter.apiFilter,
      );

      state = state.copyWith(
        status: LoadingStatus.success,
        surfaces: surfaces,
        tasks: surfaces.tasksFor(filter),
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        tasks: const [],
        clearSurfaces: true,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> loadTasks({TaskFilter filter = TaskFilter.due}) async {
    state = state.copyWith(
      status: LoadingStatus.loading,
      selectedFilter: filter,
      tasks: const [],
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      final tasks = await repository.getTasks(filter: filter.apiFilter);

      state = state.copyWith(
        status: LoadingStatus.success,
        tasks: tasks,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        tasks: const [],
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> loadByDay({
    required DateTime date,
    TaskFilter filter = TaskFilter.all,
  }) async {
    state = state.copyWith(
      status: LoadingStatus.loading,
      selectedDate: _localDay(date),
      selectedFilter: filter,
      tasks: const [],
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      final tasks = await repository.getTasksForDay(
        date,
        filter: filter.apiFilter,
      );

      if (kDebugMode) {
        debugPrint(
          '[TASK DAY] date=${_localDay(date)} filter=${filter.apiFilter} count=${tasks.length}',
        );
      }

      state = state.copyWith(
        status: LoadingStatus.success,
        tasks: tasks,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        tasks: const [],
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> loadInboxTasks() async {
    state = state.copyWith(
      status: LoadingStatus.loading,
      selectedFilter: TaskFilter.inbox,
      tasks: const [],
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      final tasks = await repository.getInboxTasks();

      state = state.copyWith(
        status: LoadingStatus.success,
        tasks: tasks,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        tasks: const [],
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> loadHistoryTasks({required DateTime date}) async {
    state = state.copyWith(
      status: LoadingStatus.loading,
      selectedDate: _localDay(date),
      selectedFilter: TaskFilter.history,
      tasks: const [],
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      final tasks = await repository.getHistoryTasks(date);

      state = state.copyWith(
        status: LoadingStatus.success,
        tasks: tasks,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        tasks: const [],
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> loadPausedTasks() async {
    state = state.copyWith(
      status: LoadingStatus.loading,
      selectedFilter: TaskFilter.paused,
      tasks: const [],
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      final tasks = await repository.getPausedTasks();

      state = state.copyWith(
        status: LoadingStatus.success,
        tasks: tasks,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        tasks: const [],
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> loadArchivedTasks({
    TaskFilter filter = TaskFilter.archive,
  }) async {
    state = state.copyWith(
      status: LoadingStatus.loading,
      selectedFilter: TaskFilter.archive,
      tasks: const [],
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      final tasks = await repository.getArchivedTasks(filter: filter.apiFilter);

      state = state.copyWith(
        status: LoadingStatus.success,
        tasks: tasks,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        tasks: const [],
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> loadOverview({required DateTime date}) async {
    try {
      final overview = await repository.getOverview(date);

      state = state.copyWith(
        selectedDate: _localDay(date),
        overview: overview,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        clearOverview: true,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> loadSections({
    required DateTime date,
    TaskFilter filter = TaskFilter.all,
  }) async {
    state = state.copyWith(
      status: LoadingStatus.loading,
      selectedDate: _localDay(date),
      selectedFilter: filter,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      final section = await repository.getSections(
        date,
        filter: filter.apiFilter,
      );

      final tasks = [
        ...section.urgentTasks,
        ...section.dailyTasks,
        ...section.progressTasks,
        ...section.standardTasks,
      ];

      state = state.copyWith(
        status: LoadingStatus.success,
        tasks: tasks,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        tasks: const [],
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> loadById({required String taskId, DateTime? date}) async {
    // Optional: Keep the existing task visible while loading to prevent screen flicker
    final isAlreadyLoaded = state.selectedTask?.id == taskId;

    state = state.copyWith(
      status: isAlreadyLoaded ? state.status : LoadingStatus.loading,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      // --- THE FIX ---
      // We removed the local `state.tasks` loop.
      // The detail page MUST always fetch from the API to ensure
      // recurring tasks receive their daily completion overlay.
      final task = await repository.getTaskById(taskId, date: date);

      state = state.copyWith(
        status: LoadingStatus.success,
        selectedTask: task,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        clearSelectedTask: true,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> createTask({required CreateTaskCommand command}) async {
    state = state.copyWith(
      mutationStatus: LoadingStatus.saving,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    final validationError = validationPolicy.validateCreate(command);
    if (validationError != null) {
      state = state.copyWith(
        mutationStatus: LoadingStatus.error,
        errorMessage: validationError,
      );
      return;
    }

    try {
      final task = await repository.createTask(command);

      state = state.copyWith(
        mutationStatus: LoadingStatus.success,
        selectedTask: task,
        successMessage: TaskCopy.successCreated,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        mutationStatus: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );

      rethrow;
    }
  }

  Future<void> updateTask({
    required String taskId,
    required UpdateTaskCommand command,
  }) async {
    state = state.copyWith(
      mutationStatus: LoadingStatus.saving,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    final validationError = validationPolicy.validateUpdate(command);
    if (validationError != null) {
      state = state.copyWith(
        mutationStatus: LoadingStatus.error,
        errorMessage: validationError,
      );
      return;
    }

    try {
      final task = await repository.updateTask(taskId, command);

      state = state.copyWith(
        mutationStatus: LoadingStatus.success,
        selectedTask: task,
        successMessage: TaskCopy.successUpdated,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        mutationStatus: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );

      rethrow;
    }
  }

  Future<void> completeTask({
    required String taskId,
    required DateTime date,
  }) async {
    state = state.copyWith(
      mutationStatus: LoadingStatus.saving,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      final task = await repository.completeTask(taskId, date: date);

      state = state.copyWith(
        mutationStatus: LoadingStatus.success,
        selectedTask: task,
        successMessage: TaskCopy.successCompleted,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        mutationStatus: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );

      rethrow;
    }
  }

  Future<void> reopenTask({
    required String taskId,
    required DateTime date,
  }) async {
    state = state.copyWith(
      mutationStatus: LoadingStatus.saving,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      final task = await repository.reopenTask(taskId, date: date);

      state = state.copyWith(
        mutationStatus: LoadingStatus.success,
        selectedTask: task,
        successMessage: TaskCopy.successReopened,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        mutationStatus: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );

      rethrow;
    }
  }

  Future<void> clearDoneForDay({required DateTime date}) async {
    state = state.copyWith(
      mutationStatus: LoadingStatus.saving,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      await repository.clearDoneForDay(date);

      state = state.copyWith(
        mutationStatus: LoadingStatus.success,
        successMessage: TaskCopy.successDoneCleared,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        mutationStatus: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );

      rethrow;
    }
  }

  Future<void> pauseTask({required String taskId, DateTime? until}) async {
    state = state.copyWith(
      mutationStatus: LoadingStatus.saving,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      final task = await repository.pauseTask(taskId, until: until);

      state = state.copyWith(
        mutationStatus: LoadingStatus.success,
        selectedTask: task,
        successMessage: TaskCopy.successPaused,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        mutationStatus: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );

      rethrow;
    }
  }

  Future<void> resumeTask({required String taskId}) async {
    state = state.copyWith(
      mutationStatus: LoadingStatus.saving,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      final task = await repository.resumeTask(taskId);

      state = state.copyWith(
        mutationStatus: LoadingStatus.success,
        selectedTask: task,
        successMessage: TaskCopy.successResumed,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        mutationStatus: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );

      rethrow;
    }
  }

  Future<void> archiveTask({required String taskId}) async {
    state = state.copyWith(
      mutationStatus: LoadingStatus.saving,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      await repository.archiveTask(taskId);

      state = state.copyWith(
        mutationStatus: LoadingStatus.success,
        clearSelectedTask: true,
        successMessage: TaskCopy.successArchived,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        mutationStatus: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );

      rethrow;
    }
  }

  Future<void> restoreTask({required String taskId}) async {
    state = state.copyWith(
      mutationStatus: LoadingStatus.saving,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      await repository.restoreTask(taskId);

      state = state.copyWith(
        mutationStatus: LoadingStatus.success,
        clearSelectedTask: true,
        successMessage: TaskCopy.successRestored,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        mutationStatus: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );

      rethrow;
    }
  }

  Future<void> deleteTask({required String taskId}) async {
    state = state.copyWith(
      mutationStatus: LoadingStatus.saving,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      await repository.deleteTask(taskId);

      state = state.copyWith(
        mutationStatus: LoadingStatus.success,
        clearSelectedTask: true,
        successMessage: TaskCopy.successDeletedPermanently,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        mutationStatus: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );

      rethrow;
    }
  }

  DateTime _localDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
