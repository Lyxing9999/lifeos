import 'task_response_dto.dart';

class TaskSectionResponseDto {
  final List<TaskResponseDto> urgentTasks;
  final List<TaskResponseDto> dailyTasks;
  final List<TaskResponseDto> progressTasks;
  final List<TaskResponseDto> standardTasks;

  const TaskSectionResponseDto({
    required this.urgentTasks,
    required this.dailyTasks,
    required this.progressTasks,
    required this.standardTasks,
  });

  factory TaskSectionResponseDto.fromJson(Map<String, dynamic> json) {
    return TaskSectionResponseDto(
      urgentTasks: _parseTasks(json['urgentTasks']),
      dailyTasks: _parseTasks(json['dailyTasks']),
      progressTasks: _parseTasks(json['progressTasks']),
      standardTasks: _parseTasks(json['standardTasks']),
    );
  }

  static List<TaskResponseDto> _parseTasks(dynamic raw) {
    return (raw as List<dynamic>? ?? [])
        .map((item) => TaskResponseDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
