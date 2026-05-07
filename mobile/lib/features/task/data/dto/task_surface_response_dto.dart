import 'task_count_summary_response_dto.dart';
import 'task_response_dto.dart';

class TaskSurfaceResponseDto {
  final String? date;
  final String? filter;

  final List<TaskResponseDto> dueTasks;
  final List<TaskResponseDto> inboxTasks;
  final List<TaskResponseDto> doneTasks;
  final List<TaskResponseDto> historyTasks;
  final List<TaskResponseDto> pausedTasks;
  final List<TaskResponseDto> archivedTasks;
  final List<TaskResponseDto> allTasks;

  final TaskCountSummaryResponseDto? dueCounts;
  final TaskCountSummaryResponseDto? inboxCounts;
  final TaskCountSummaryResponseDto? doneCounts;
  final TaskCountSummaryResponseDto? historyCounts;
  final TaskCountSummaryResponseDto? pausedCounts;
  final TaskCountSummaryResponseDto? archivedCounts;
  final TaskCountSummaryResponseDto? allCounts;

  const TaskSurfaceResponseDto({
    required this.date,
    required this.filter,
    required this.dueTasks,
    required this.inboxTasks,
    required this.doneTasks,
    required this.historyTasks,
    required this.pausedTasks,
    required this.archivedTasks,
    required this.allTasks,
    required this.dueCounts,
    required this.inboxCounts,
    required this.doneCounts,
    required this.historyCounts,
    required this.pausedCounts,
    required this.archivedCounts,
    required this.allCounts,
  });

  factory TaskSurfaceResponseDto.fromJson(Map<String, dynamic> json) {
    return TaskSurfaceResponseDto(
      date: json['date'] as String?,
      filter: json['filter'] as String?,

      dueTasks: _taskList(json['dueTasks']),
      inboxTasks: _taskList(json['inboxTasks']),
      doneTasks: _taskList(json['doneTasks']),
      historyTasks: _taskList(json['historyTasks']),
      pausedTasks: _taskList(json['pausedTasks']),
      archivedTasks: _taskList(json['archivedTasks']),
      allTasks: _taskList(json['allTasks']),

      dueCounts: _count(json['dueCounts']),
      inboxCounts: _count(json['inboxCounts']),
      doneCounts: _count(json['doneCounts']),
      historyCounts: _count(json['historyCounts']),
      pausedCounts: _count(json['pausedCounts']),
      archivedCounts: _count(json['archivedCounts']),
      allCounts: _count(json['allCounts']),
    );
  }

  static List<TaskResponseDto> _taskList(Object? raw) {
    return (raw as List<dynamic>? ?? const [])
        .map((item) => TaskResponseDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static TaskCountSummaryResponseDto? _count(Object? raw) {
    if (raw == null) return null;
    return TaskCountSummaryResponseDto.fromJson(raw as Map<String, dynamic>);
  }
}
