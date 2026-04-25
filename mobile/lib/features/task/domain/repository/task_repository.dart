import '../../data/dto/create_task_request_dto.dart';
import '../../data/dto/update_task_request_dto.dart';
import '../model/task.dart';
import '../model/task_overview.dart';
import '../model/task_section.dart';

abstract class TaskRepository {
  Future<Task> createTask(CreateTaskRequestDto request);
  Future<Task> updateTask(String taskId, UpdateTaskRequestDto request);
  Future<Task> completeTask(String taskId);

  Future<List<Task>> getTasksByUser(String userId, {String filter = 'ACTIVE'});
  Future<List<Task>> getTasksForDay(
    String userId,
    DateTime date, {
    String filter = 'ALL',
  });
  Future<TaskOverview> getOverview(String userId, DateTime date);
  Future<TaskSection> getSections(
    String userId,
    DateTime date, {
    String filter = 'ALL',
  });

  Future<Task?> getTaskById(String userId, String taskId);
  Future<void> deleteTask(String taskId);
}
