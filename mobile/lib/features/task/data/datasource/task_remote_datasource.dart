import '../../../../core/network/api_client.dart';
import '../dto/create_task_request_dto.dart';
import '../dto/task_overview_response_dto.dart';
import '../dto/task_response_dto.dart';
import '../dto/task_section_response_dto.dart';
import '../dto/update_task_request_dto.dart';

class TaskRemoteDataSource {
  final ApiClient apiClient;

  const TaskRemoteDataSource(this.apiClient);

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

  Future<TaskResponseDto> completeTask(String taskId) {
    return apiClient.post(
      '/tasks/$taskId/complete',
      parser: (rawData) =>
          TaskResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<List<TaskResponseDto>> getTasksByUser(
    String userId, {
    String filter = 'ACTIVE',
  }) {
    return apiClient.get(
      '/tasks/user/$userId',
      queryParameters: {'filter': filter},
      parser: (rawData) => (rawData as List<dynamic>? ?? [])
          .map((item) => TaskResponseDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<List<TaskResponseDto>> getTasksForDay(
    String userId,
    DateTime date, {
    String filter = 'ALL',
  }) {
    return apiClient.get(
      '/tasks/user/$userId/day',
      queryParameters: {'date': _formatDate(date), 'filter': filter},
      parser: (rawData) => (rawData as List<dynamic>? ?? [])
          .map((item) => TaskResponseDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<TaskOverviewResponseDto> getOverview(String userId, DateTime date) {
    return apiClient.get(
      '/tasks/user/$userId/overview',
      queryParameters: {'date': _formatDate(date)},
      parser: (rawData) =>
          TaskOverviewResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<TaskSectionResponseDto> getSections(
    String userId,
    DateTime date, {
    String filter = 'ALL',
  }) {
    return apiClient.get(
      '/tasks/user/$userId/sections',
      queryParameters: {'date': _formatDate(date), 'filter': filter},
      parser: (rawData) =>
          TaskSectionResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<void> deleteTask(String taskId) {
    return apiClient.deleteVoid('/tasks/$taskId');
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
