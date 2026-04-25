import '../../domain/model/task.dart';
import '../../domain/model/task_overview.dart';
import '../../domain/model/task_section.dart';
import '../../domain/repository/task_repository.dart';
import '../datasource/task_remote_datasource.dart';
import '../dto/create_task_request_dto.dart';
import '../dto/update_task_request_dto.dart';
import '../mapper/task_mapper.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  final TaskMapper mapper;

  const TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.mapper,
  });

  @override
  Future<Task> createTask(CreateTaskRequestDto request) async {
    final dto = await remoteDataSource.createTask(request);
    return mapper.toDomain(dto);
  }

  @override
  Future<Task> updateTask(String taskId, UpdateTaskRequestDto request) async {
    final dto = await remoteDataSource.updateTask(taskId, request);
    return mapper.toDomain(dto);
  }

  @override
  Future<Task> completeTask(String taskId) async {
    final dto = await remoteDataSource.completeTask(taskId);
    return mapper.toDomain(dto);
  }

  @override
  Future<List<Task>> getTasksByUser(
    String userId, {
    String filter = 'ACTIVE',
  }) async {
    final dtos = await remoteDataSource.getTasksByUser(userId, filter: filter);
    return dtos.map(mapper.toDomain).toList();
  }

  @override
  Future<List<Task>> getTasksForDay(
    String userId,
    DateTime date, {
    String filter = 'ALL',
  }) async {
    final dtos = await remoteDataSource.getTasksForDay(
      userId,
      date,
      filter: filter,
    );
    return dtos.map(mapper.toDomain).toList();
  }

  @override
  Future<TaskOverview> getOverview(String userId, DateTime date) async {
    final dto = await remoteDataSource.getOverview(userId, date);
    return mapper.toOverviewDomain(dto);
  }

  @override
  Future<TaskSection> getSections(
    String userId,
    DateTime date, {
    String filter = 'ALL',
  }) async {
    final dto = await remoteDataSource.getSections(
      userId,
      date,
      filter: filter,
    );
    return mapper.toSectionDomain(dto);
  }

  @override
  Future<Task?> getTaskById(String userId, String taskId) async {
    final dtos = await remoteDataSource.getTasksByUser(userId, filter: 'ALL');
    for (final dto in dtos) {
      if (dto.id == taskId) {
        return mapper.toDomain(dto);
      }
    }
    return null;
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await remoteDataSource.deleteTask(taskId);
  }
}
