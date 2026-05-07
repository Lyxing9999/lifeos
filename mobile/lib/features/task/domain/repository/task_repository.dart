import '../command/create_task_command.dart';
import '../command/update_task_command.dart';
import '../entities/schedule_select_option.dart';
import '../entities/task.dart';
import '../entities/task_overview.dart';
import '../entities/task_section.dart';
import '../entities/task_surface.dart';

abstract class TaskRepository {
  Future<TaskSurfaceOverview> getSurfaces({
    required DateTime date,
    String filter = 'ACTIVE',
  });
  Future<List<Task>> getTasks({String filter = 'ACTIVE'});
  Future<List<Task>> getTasksForDay(DateTime date, {String filter = 'ALL'});
  Future<List<Task>> getInboxTasks();
  Future<List<Task>> getHistoryTasks(DateTime date);
  Future<List<Task>> getPausedTasks();
  Future<List<Task>> getArchivedTasks({String filter = 'ALL'});
  Future<Task> createTask(CreateTaskCommand command);
  Future<Task> updateTask(String taskId, UpdateTaskCommand command);
  Future<Task> completeTask(String taskId, {DateTime? date});
  Future<Task> reopenTask(String taskId, {DateTime? date});
  Future<String> clearDoneForDay(DateTime date);
  Future<Task> pauseTask(String taskId, {DateTime? until});
  Future<Task> resumeTask(String taskId);
  Future<Task> archiveTask(String taskId);
  Future<Task> restoreTask(String taskId);
  Future<void> deleteTask(String taskId);
  Future<TaskOverview> getOverview(DateTime date);
  Future<TaskSection> getSections(DateTime date, {String filter = 'ALL'});
  Future<Task> getTaskById(String taskId, {DateTime? date});
  Future<List<ScheduleSelectOption>> getScheduleSelectOptions();
}
