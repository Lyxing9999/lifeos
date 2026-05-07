import 'package:lifeos_mobile/features/task/domain/command/create_task_command.dart';
import 'package:lifeos_mobile/features/task/domain/command/update_task_command.dart';
import 'package:lifeos_mobile/features/task/domain/entities/schedule_select_option.dart';
import 'package:lifeos_mobile/features/task/domain/entities/task.dart';
import 'package:lifeos_mobile/features/task/domain/entities/task_overview.dart';
import 'package:lifeos_mobile/features/task/domain/entities/task_section.dart';
import 'package:lifeos_mobile/features/task/domain/entities/task_surface.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_mode.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_priority.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_recurrence_type.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_status.dart';
import 'package:lifeos_mobile/features/task/domain/repository/task_repository.dart';

class FakeTaskRepository implements TaskRepository {
  List<Task> tasks = const [];
  Task? selectedTask;
  TaskOverview? overview;
  TaskSurfaceOverview? surfaces;
  TaskSection? section;
  Object? error;

  void throwError(Object value) {
    error = value;
  }

  void clearError() {
    error = null;
  }

  void _maybeThrow() {
    final e = error;
    if (e != null) throw e;
  }

  @override
  Future<List<Task>> getTasks({String filter = 'ACTIVE'}) async {
    _maybeThrow();
    return tasks;
  }

  @override
  Future<List<Task>> getTasksForDay(
    DateTime date, {
    String filter = 'ALL',
  }) async {
    _maybeThrow();
    return tasks;
  }

  @override
  Future<TaskSection> getSections(
    DateTime date, {
    String filter = 'ALL',
  }) async {
    _maybeThrow();
    return section ?? const TaskSection.empty();
  }

  @override
  Future<TaskSurfaceOverview> getSurfaces({
    required DateTime date,
    String filter = 'ACTIVE',
  }) async {
    _maybeThrow();

    final value = surfaces;
    if (value == null) {
      throw StateError('Fake surfaces not set');
    }

    return value;
  }

  @override
  Future<TaskOverview> getOverview(DateTime date) async {
    _maybeThrow();

    final value = overview;
    if (value == null) {
      throw StateError('Fake overview not set');
    }

    return value;
  }

  @override
  Future<Task> getTaskById(String taskId, {DateTime? date}) async {
    _maybeThrow();

    if (selectedTask != null) return selectedTask!;

    for (final task in tasks) {
      if (task.id == taskId) return task;
    }

    throw StateError('Fake task not found');
  }

  @override
  Future<Task> createTask(CreateTaskCommand command) async {
    _maybeThrow();

    final task = selectedTask;
    if (task == null) {
      throw StateError('Fake selectedTask not set');
    }

    return task;
  }

  @override
  Future<Task> updateTask(String taskId, UpdateTaskCommand command) async {
    _maybeThrow();

    final task = selectedTask;
    if (task == null) {
      throw StateError('Fake selectedTask not set');
    }

    return task;
  }

  @override
  Future<Task> completeTask(String taskId, {DateTime? date}) async {
    _maybeThrow();

    final task = selectedTask;
    if (task == null) {
      throw StateError('Fake selectedTask not set');
    }

    return task;
  }

  @override
  Future<Task> reopenTask(String taskId, {DateTime? date}) async {
    _maybeThrow();

    final task = selectedTask;
    if (task == null) {
      throw StateError('Fake selectedTask not set');
    }

    return task;
  }

  @override
  Future<Task> pauseTask(String taskId, {DateTime? until}) async {
    _maybeThrow();

    final task = selectedTask;
    if (task == null) {
      throw StateError('Fake selectedTask not set');
    }

    return task;
  }

  @override
  Future<Task> resumeTask(String taskId) async {
    _maybeThrow();

    final task = selectedTask;
    if (task == null) {
      throw StateError('Fake selectedTask not set');
    }

    return task;
  }

  @override
  Future<String> clearDoneForDay(DateTime date) async {
    _maybeThrow();
    return 'Done list cleared';
  }

  @override
  Future<List<Task>> getInboxTasks() async {
    _maybeThrow();
    return tasks;
  }

  @override
  Future<List<Task>> getHistoryTasks(DateTime date) async {
    _maybeThrow();
    return tasks;
  }

  @override
  Future<List<Task>> getPausedTasks() async {
    _maybeThrow();
    return tasks;
  }

  @override
  Future<List<Task>> getArchivedTasks({String filter = 'ALL'}) async {
    _maybeThrow();
    return tasks;
  }

  @override
  Future<Task> archiveTask(String taskId) async {
    _maybeThrow();
    return selectedTask ??
        (tasks.isEmpty ? _fallbackTask(archived: true) : tasks.first);
  }

  @override
  Future<Task> restoreTask(String taskId) async {
    _maybeThrow();
    return selectedTask ?? (tasks.isEmpty ? _fallbackTask() : tasks.first);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    _maybeThrow();
  }

  @override
  Future<List<ScheduleSelectOption>> getScheduleSelectOptions() async {
    _maybeThrow();
    return const [];
  }

  Task _fallbackTask({bool archived = false}) {
    return Task(
      id: 'task-1',
      userId: 'user-1',
      title: 'Task',
      status: TaskStatus.todo,
      taskMode: TaskMode.standard,
      priority: TaskPriority.medium,
      progressPercent: 0,
      archived: archived,
      paused: false,
      recurrenceType: TaskRecurrenceType.none,
      recurrenceDaysOfWeek: const [],
      tags: const [],
    );
  }
}
