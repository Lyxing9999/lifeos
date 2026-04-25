import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_status.dart';

import '../../../core/enums/loading_status.dart';
import '../../../core/error/error_mapper.dart';
import '../content/task_copy.dart';
import '../data/dto/create_task_request_dto.dart';
import '../data/dto/update_task_request_dto.dart';
import '../domain/model/task.dart';
import '../domain/repository/task_repository.dart';
import 'task_state.dart';

class TaskNotifier extends StateNotifier<TaskState> {
  final TaskRepository repository;

  TaskNotifier(this.repository) : super(TaskState.initial());

  Future<void> loadTasks(String userId, {String filter = 'ACTIVE'}) async {
    state = state.copyWith(
      status: LoadingStatus.loading,
      selectedFilter: filter,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final tasks = await repository.getTasksByUser(userId, filter: filter);
      state = state.copyWith(
        status: LoadingStatus.success,
        tasks: tasks,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> loadByDay({
    required String userId,
    required DateTime date,
    String filter = 'ALL',
  }) async {
    state = state.copyWith(
      status: LoadingStatus.loading,
      selectedDate: date,
      selectedFilter: filter,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final tasks = await repository.getTasksForDay(
        userId,
        date,
        filter: filter,
      );
      state = state.copyWith(
        status: LoadingStatus.success,
        tasks: tasks,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        tasks: const [],
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> loadOverview({
    required String userId,
    required DateTime date,
  }) async {
    state = state.copyWith(
      status: LoadingStatus.loading,
      selectedDate: date,
      errorMessage: null,
    );

    try {
      final overview = await repository.getOverview(userId, date);
      state = state.copyWith(
        status: LoadingStatus.success,
        overview: overview,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        overview: null,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> loadById({
    required String userId,
    required String taskId,
  }) async {
    state = state.copyWith(status: LoadingStatus.loading, errorMessage: null);

    try {
      Task? existing;
      for (final task in state.tasks) {
        if (task.id == taskId) {
          existing = task;
          break;
        }
      }
      final task = existing ?? await repository.getTaskById(userId, taskId);
      if (task == null) {
        throw StateError(TaskCopy.errorNotFound);
      }
      state = state.copyWith(
        status: LoadingStatus.success,
        selectedTask: task,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        selectedTask: null,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> createTask({
    required String userId,
    required CreateTaskRequestDto request,
  }) async {
    state = state.copyWith(
      status: LoadingStatus.saving,
      errorMessage: null,
      successMessage: null,
    );

    try {
      await repository.createTask(request);

      state = state.copyWith(
        status: LoadingStatus.success,
        successMessage: TaskCopy.successCreated,
      );

      await loadTasks(userId, filter: state.selectedFilter ?? 'ACTIVE');
      await loadOverview(userId: userId, date: state.selectedDate);
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> updateTask({
    required String userId,
    required String taskId,
    required UpdateTaskRequestDto request,
  }) async {
    state = state.copyWith(
      status: LoadingStatus.saving,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final task = await repository.updateTask(taskId, request);

      state = state.copyWith(
        status: LoadingStatus.success,
        selectedTask: task,
        successMessage: TaskCopy.successUpdated,
      );

      await loadTasks(userId, filter: state.selectedFilter ?? 'ACTIVE');
      await loadOverview(userId: userId, date: state.selectedDate);
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> completeTask({
    required String userId,
    required String taskId,
  }) async {
    state = state.copyWith(
      status: LoadingStatus.saving,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final task = await repository.completeTask(taskId);

      state = state.copyWith(
        status: LoadingStatus.success,
        selectedTask: task,
        successMessage: TaskCopy.successCompleted,
      );

      await loadTasks(userId, filter: state.selectedFilter ?? 'ACTIVE');
      await loadOverview(userId: userId, date: state.selectedDate);
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> deleteTask({
    required String userId,
    required String taskId,
  }) async {
    state = state.copyWith(
      status: LoadingStatus.saving,
      errorMessage: null,
      successMessage: null,
    );

    try {
      await repository.deleteTask(taskId);

      state = state.copyWith(
        status: LoadingStatus.success,
        selectedTask: null,
        successMessage: TaskCopy.successDeleted,
      );

      await loadTasks(userId, filter: state.selectedFilter ?? 'ACTIVE');
      await loadOverview(userId: userId, date: state.selectedDate);
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  List<Task> get activeTasks =>
      state.tasks.where((task) => !task.status.isDone).toList();

  List<Task> get completedTasksList =>
      state.tasks.where((task) => task.status.isDone).toList();
}
