import '../../../../core/time/api_date_formatter.dart';
import '../../domain/command/create_task_command.dart';
import '../../domain/command/update_task_command.dart';
import '../../domain/entities/schedule_select_option.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_overview.dart';
import '../../domain/entities/task_section.dart';
import '../../domain/entities/task_surface.dart';
import '../../domain/repository/task_repository.dart';
import '../datasource/task_remote_datasource.dart';
import '../dto/create_task_request_dto.dart';
import '../dto/update_task_request_dto.dart';
import '../mapper/schedule_select_option_mapper.dart';
import '../mapper/task_mapper.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  final TaskMapper mapper;
  final ScheduleSelectOptionMapper scheduleSelectOptionMapper;
  final ApiDateFormatter dateFormatter;

  const TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.mapper,
    required this.scheduleSelectOptionMapper,
    required this.dateFormatter,
  });

  @override
  Future<TaskSurfaceOverview> getSurfaces({
    required DateTime date,
    String filter = 'ACTIVE',
  }) async {
    final dto = await remoteDataSource.getSurfaces(date, filter: filter);

    return mapper.toSurfaceDomain(dto);
  }

  @override
  Future<List<Task>> getTasks({String filter = 'ACTIVE'}) async {
    final dtos = await remoteDataSource.getTasks(filter: filter);

    return dtos.map(mapper.toDomain).toList();
  }

  @override
  Future<List<Task>> getTasksForDay(
    DateTime date, {
    String filter = 'ALL',
  }) async {
    final dtos = await remoteDataSource.getTasksForDay(date, filter: filter);

    return dtos.map(mapper.toDomain).toList();
  }

  @override
  Future<List<Task>> getInboxTasks() async {
    final dtos = await remoteDataSource.getInboxTasks();

    return dtos.map(mapper.toDomain).toList();
  }

  @override
  Future<List<Task>> getHistoryTasks(DateTime date) async {
    final dtos = await remoteDataSource.getHistoryTasks(date);

    return dtos.map(mapper.toDomain).toList();
  }

  @override
  Future<List<Task>> getPausedTasks() async {
    final dtos = await remoteDataSource.getPausedTasks();

    return dtos.map(mapper.toDomain).toList();
  }

  @override
  Future<List<Task>> getArchivedTasks({String filter = 'ALL'}) async {
    final dtos = await remoteDataSource.getArchivedTasks(filter: filter);

    return dtos.map(mapper.toDomain).toList();
  }

  @override
  Future<Task> createTask(CreateTaskCommand command) async {
    final request = CreateTaskRequestDto.fromCommand(
      command,
      dateFormatter: dateFormatter,
    );

    final dto = await remoteDataSource.createTask(request);

    return mapper.toDomain(dto);
  }

  @override
  Future<Task> updateTask(String taskId, UpdateTaskCommand command) async {
    final request = UpdateTaskRequestDto.fromCommand(
      command,
      dateFormatter: dateFormatter,
    );

    final dto = await remoteDataSource.updateTask(taskId, request);

    return mapper.toDomain(dto);
  }

  @override
  Future<Task> completeTask(String taskId, {DateTime? date}) async {
    final dto = await remoteDataSource.completeTask(taskId, date: date);

    return mapper.toDomain(dto);
  }

  @override
  Future<Task> reopenTask(String taskId, {DateTime? date}) async {
    final dto = await remoteDataSource.reopenTask(taskId, date: date);

    return mapper.toDomain(dto);
  }

  @override
  Future<String> clearDoneForDay(DateTime date) async {
    await remoteDataSource.clearDoneForDay(date);

    return 'Done list cleared';
  }

  @override
  Future<Task> pauseTask(String taskId, {DateTime? until}) async {
    final dto = await remoteDataSource.pauseTask(taskId, until: until);

    return mapper.toDomain(dto);
  }

  @override
  Future<Task> resumeTask(String taskId) async {
    final dto = await remoteDataSource.resumeTask(taskId);

    return mapper.toDomain(dto);
  }

  @override
  Future<Task> archiveTask(String taskId) async {
    final dto = await remoteDataSource.archiveTask(taskId);

    return mapper.toDomain(dto);
  }

  @override
  Future<Task> restoreTask(String taskId) async {
    final dto = await remoteDataSource.restoreTask(taskId);

    return mapper.toDomain(dto);
  }

  @override
  Future<void> deleteTask(String taskId) {
    return remoteDataSource.deleteTask(taskId);
  }

  @override
  Future<TaskOverview> getOverview(DateTime date) async {
    final dto = await remoteDataSource.getOverview(date);

    return mapper.toOverviewDomain(dto);
  }

  @override
  Future<TaskSection> getSections(
    DateTime date, {
    String filter = 'ALL',
  }) async {
    final dto = await remoteDataSource.getSections(date, filter: filter);

    return mapper.toSectionDomain(dto);
  }

  @override
  Future<Task> getTaskById(String taskId, {DateTime? date}) async {
    final dto = await remoteDataSource.getTaskById(taskId, date: date);
    return mapper.toDomain(dto);
  }

  @override
  Future<List<ScheduleSelectOption>> getScheduleSelectOptions({
    DateTime? date,
  }) async {
    final dtos = await remoteDataSource.getScheduleSelectOptions(
      DateTime.now(),
    );

    return dtos.map(scheduleSelectOptionMapper.toDomain).toList();
  }
}
