import 'task_response_dto.dart';

class TaskSectionResponseDto {
  final List<TaskResponseDto> urgentTasks;
  final List<TaskResponseDto> dailyTasks;
  final List<TaskResponseDto> progressTasks;
  final List<TaskResponseDto> standardTasks;

  const TaskSectionResponseDto({
    this.urgentTasks = const [],
    this.dailyTasks = const [],
    this.progressTasks = const [],
    this.standardTasks = const [],
  });

  factory TaskSectionResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TaskSectionResponseDto();

    return TaskSectionResponseDto(
      urgentTasks: _parseTaskList(json['urgentTasks']),
      dailyTasks: _parseTaskList(json['dailyTasks']),
      progressTasks: _parseTaskList(json['progressTasks']),
      standardTasks: _parseTaskList(json['standardTasks']),
    );
  }

  static List<TaskResponseDto> _parseTaskList(Object? raw) {
    if (raw == null) return const [];
    if (raw is! List) return const [];

    return raw
        .whereType<Map<String, dynamic>>()
        .map(TaskResponseDto.fromJson)
        .toList();
  }
}
