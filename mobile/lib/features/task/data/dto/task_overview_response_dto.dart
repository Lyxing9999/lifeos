import 'task_count_summary_dto.dart';
import 'task_response_dto.dart';
import 'task_section_response_dto.dart';

class TaskOverviewResponseDto {
  final String? date;
  final TaskResponseDto? currentTask;
  final TaskResponseDto? currentUrgentTask;
  final TaskResponseDto? currentDailyTask;
  final TaskResponseDto? currentProgressTask;
  final TaskSectionResponseDto? todaySections;
  final TaskSectionResponseDto? last3DaySections;
  final TaskSectionResponseDto? last7DaySections;
  final TaskSectionResponseDto? last30DaySections;
  final TaskCountSummaryDto? todayCounts;
  final TaskCountSummaryDto? last3DayCounts;
  final TaskCountSummaryDto? last7DayCounts;
  final TaskCountSummaryDto? last30DayCounts;
  final List<TaskResponseDto> recentCompletedTasks;

  const TaskOverviewResponseDto({
    required this.date,
    required this.currentTask,
    required this.currentUrgentTask,
    required this.currentDailyTask,
    required this.currentProgressTask,
    required this.todaySections,
    required this.last3DaySections,
    required this.last7DaySections,
    required this.last30DaySections,
    required this.todayCounts,
    required this.last3DayCounts,
    required this.last7DayCounts,
    required this.last30DayCounts,
    required this.recentCompletedTasks,
  });

  factory TaskOverviewResponseDto.fromJson(Map<String, dynamic> json) {
    return TaskOverviewResponseDto(
      date: json['date'] as String?,
      currentTask: _parseTask(json['currentTask']),
      currentUrgentTask: _parseTask(json['currentUrgentTask']),
      currentDailyTask: _parseTask(json['currentDailyTask']),
      currentProgressTask: _parseTask(json['currentProgressTask']),
      todaySections: _parseSection(json['todaySections']),
      last3DaySections: _parseSection(json['last3DaySections']),
      last7DaySections: _parseSection(json['last7DaySections']),
      last30DaySections: _parseSection(json['last30DaySections']),
      todayCounts: _parseCounts(json['todayCounts']),
      last3DayCounts: _parseCounts(json['last3DayCounts']),
      last7DayCounts: _parseCounts(json['last7DayCounts']),
      last30DayCounts: _parseCounts(json['last30DayCounts']),
      recentCompletedTasks:
          (json['recentCompletedTasks'] as List<dynamic>? ?? [])
              .map(
                (item) =>
                    TaskResponseDto.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  static TaskResponseDto? _parseTask(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return TaskResponseDto.fromJson(raw);
    }
    return null;
  }

  static TaskSectionResponseDto? _parseSection(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return TaskSectionResponseDto.fromJson(raw);
    }
    return null;
  }

  static TaskCountSummaryDto? _parseCounts(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return TaskCountSummaryDto.fromJson(raw);
    }
    return null;
  }
}
