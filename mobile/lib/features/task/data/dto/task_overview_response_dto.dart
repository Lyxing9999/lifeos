import 'task_count_summary_response_dto.dart';
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

  final TaskCountSummaryResponseDto? todayCounts;
  final TaskCountSummaryResponseDto? last3DayCounts;
  final TaskCountSummaryResponseDto? last7DayCounts;
  final TaskCountSummaryResponseDto? last30DayCounts;

  final TaskCountSummaryResponseDto? anytimeCounts;
  final List<TaskResponseDto> anytimePreviewTasks;

  final List<TaskResponseDto> recentCompletedTasks;

  const TaskOverviewResponseDto({
    this.date,
    this.currentTask,
    this.currentUrgentTask,
    this.currentDailyTask,
    this.currentProgressTask,
    this.todaySections,
    this.last3DaySections,
    this.last7DaySections,
    this.last30DaySections,
    this.todayCounts,
    this.last3DayCounts,
    this.last7DayCounts,
    this.last30DayCounts,
    this.anytimeCounts,
    this.anytimePreviewTasks = const [],
    this.recentCompletedTasks = const [],
  });

  factory TaskOverviewResponseDto.fromJson(Map<String, dynamic> json) {
    return TaskOverviewResponseDto(
      date: json['date'] as String?,
      currentTask: _parseTask(json['currentTask']),
      currentUrgentTask: _parseTask(json['currentUrgentTask']),
      currentDailyTask: _parseTask(json['currentDailyTask']),
      currentProgressTask: _parseTask(json['currentProgressTask']),
      todaySections: TaskSectionResponseDto.fromJson(
        json['todaySections'] as Map<String, dynamic>?,
      ),
      last3DaySections: TaskSectionResponseDto.fromJson(
        json['last3DaySections'] as Map<String, dynamic>?,
      ),
      last7DaySections: TaskSectionResponseDto.fromJson(
        json['last7DaySections'] as Map<String, dynamic>?,
      ),
      last30DaySections: TaskSectionResponseDto.fromJson(
        json['last30DaySections'] as Map<String, dynamic>?,
      ),
      todayCounts: TaskCountSummaryResponseDto.fromJson(
        json['todayCounts'] as Map<String, dynamic>?,
      ),
      last3DayCounts: TaskCountSummaryResponseDto.fromJson(
        json['last3DayCounts'] as Map<String, dynamic>?,
      ),
      last7DayCounts: TaskCountSummaryResponseDto.fromJson(
        json['last7DayCounts'] as Map<String, dynamic>?,
      ),
      last30DayCounts: TaskCountSummaryResponseDto.fromJson(
        json['last30DayCounts'] as Map<String, dynamic>?,
      ),
      anytimeCounts: TaskCountSummaryResponseDto.fromJson(
        json['anytimeCounts'] as Map<String, dynamic>?,
      ),
      anytimePreviewTasks: _parseTaskList(json['anytimePreviewTasks']),
      recentCompletedTasks: _parseTaskList(json['recentCompletedTasks']),
    );
  }

  static TaskResponseDto? _parseTask(Object? raw) {
    if (raw == null) return null;
    if (raw is! Map<String, dynamic>) return null;
    return TaskResponseDto.fromJson(raw);
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
