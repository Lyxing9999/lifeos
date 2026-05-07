import '../../../../core/network/api_client.dart';
import '../../../../core/time/api_date_formatter.dart';
import '../dto/create_task_request_dto.dart';
import '../dto/schedule_select_option_dto.dart';
import '../dto/task_overview_response_dto.dart';
import '../dto/task_response_dto.dart';
import '../dto/task_section_response_dto.dart';
import '../dto/task_surface_response_dto.dart';
import '../dto/update_task_request_dto.dart';

class TaskRemoteDataSource {
  final ApiClient apiClient;
  final ApiDateFormatter dateFormatter;

  const TaskRemoteDataSource({
    required this.apiClient,
    required this.dateFormatter,
  });

  Future<TaskResponseDto> createTask(CreateTaskRequestDto request) {
    return apiClient.post(
      '/tasks',
      data: request.toJson(),
      parser: (rawData) =>
          TaskResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<TaskResponseDto> updateTask(
    String taskId,
    UpdateTaskRequestDto request,
  ) {
    return apiClient.patch(
      '/tasks/$taskId',
      data: request.toJson(),
      parser: (rawData) =>
          TaskResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<TaskResponseDto> completeTask(String taskId, {DateTime? date}) {
    return apiClient.post(
      '/tasks/$taskId/complete',
      queryParameters: date == null
          ? null
          : {'date': dateFormatter.formatDate(date)},
      parser: (rawData) =>
          TaskResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<TaskResponseDto> reopenTask(String taskId, {DateTime? date}) {
    return apiClient.post(
      '/tasks/$taskId/reopen',
      queryParameters: date == null
          ? null
          : {'date': dateFormatter.formatDate(date)},
      parser: (rawData) =>
          TaskResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<TaskResponseDto> pauseTask(String taskId, {DateTime? until}) {
    return apiClient.post(
      '/tasks/$taskId/pause',
      queryParameters: until == null
          ? null
          : {'until': dateFormatter.formatDate(until)},
      parser: (rawData) =>
          TaskResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<TaskResponseDto> resumeTask(String taskId) {
    return apiClient.post(
      '/tasks/$taskId/resume',
      parser: (rawData) =>
          TaskResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<void> clearDoneForDay(DateTime date) {
    return apiClient.post(
      '/tasks/me/done/clear',
      queryParameters: {'date': dateFormatter.formatDate(date)},
      parser: (_) {},
    );
  }

  Future<void> deleteTask(String taskId) {
    return apiClient.deleteVoid('/tasks/$taskId');
  }

  Future<List<TaskResponseDto>> getTasks({String filter = 'ACTIVE'}) {
    return apiClient.get(
      '/tasks/me',
      queryParameters: {'filter': filter},
      parser: _parseTaskList,
    );
  }

  Future<List<TaskResponseDto>> getTasksForDay(
    DateTime date, {
    String filter = 'ALL',
  }) {
    return apiClient.get(
      '/tasks/me/day',
      queryParameters: {
        'date': dateFormatter.formatDate(date),
        'filter': filter,
      },
      parser: _parseTaskList,
    );
  }

  Future<TaskSectionResponseDto> getSections(
    DateTime date, {
    String filter = 'ALL',
  }) {
    return apiClient.get(
      '/tasks/me/sections',
      queryParameters: {
        'date': dateFormatter.formatDate(date),
        'filter': filter,
      },
      parser: (rawData) =>
          TaskSectionResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<List<TaskResponseDto>> getInboxTasks() {
    return apiClient.get('/tasks/me/inbox', parser: _parseTaskList);
  }

  Future<List<TaskResponseDto>> getHistoryTasks(DateTime date) {
    return apiClient.get(
      '/tasks/me/history',
      queryParameters: {'date': dateFormatter.formatDate(date)},
      parser: _parseTaskList,
    );
  }

  Future<List<TaskResponseDto>> getPausedTasks() {
    return apiClient.get('/tasks/me/paused', parser: _parseTaskList);
  }

  Future<List<TaskResponseDto>> getArchivedTasks({String filter = 'ALL'}) {
    return apiClient.get(
      '/tasks/me/archived',
      queryParameters: {'filter': filter},
      parser: _parseTaskList,
    );
  }

  Future<TaskSurfaceResponseDto> getSurfaces(
    DateTime date, {
    String filter = 'ACTIVE',
  }) {
    return apiClient.get(
      '/tasks/me/surfaces',
      queryParameters: {
        'date': dateFormatter.formatDate(date),
        'filter': filter,
      },
      parser: (rawData) {
        return TaskSurfaceResponseDto.fromJson(rawData as Map<String, dynamic>);
      },
    );
  }

  Future<TaskOverviewResponseDto> getOverview(DateTime date) {
    return apiClient.get(
      '/tasks/me/overview',
      queryParameters: {'date': dateFormatter.formatDate(date)},
      parser: (rawData) =>
          TaskOverviewResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<List<ScheduleSelectOptionDto>> getScheduleSelectOptions(
    DateTime date,
  ) {
    return apiClient.get(
      '/schedules/me/select-options',
      queryParameters: {'date': dateFormatter.formatDate(date)}, 
      parser: (rawData) {
        final list = rawData as List<dynamic>? ?? const [];
        return list
            .whereType<Map<String, dynamic>>()
            .map(ScheduleSelectOptionDto.fromJson)
            .toList();
      },
    );
  }

  Future<TaskResponseDto> archiveTask(String taskId) {
    return apiClient.post(
      '/tasks/$taskId/archive',
      parser: (rawData) =>
          TaskResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<TaskResponseDto> restoreTask(String taskId) {
    return apiClient.post(
      '/tasks/$taskId/restore',
      parser: (rawData) =>
          TaskResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<TaskResponseDto> getTaskById(String taskId, {DateTime? date}) {
    return apiClient.get(
      '/tasks/$taskId',
      queryParameters: date == null
          ? null
          : {'date': dateFormatter.formatDate(date)},
      parser: (rawData) =>
          TaskResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  List<TaskResponseDto> _parseTaskList(Object? rawData) {
    final list = rawData as List<dynamic>? ?? const [];

    return list
        .whereType<Map<String, dynamic>>()
        .map(TaskResponseDto.fromJson)
        .toList();
  }
}
