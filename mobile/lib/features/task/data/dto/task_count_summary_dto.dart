class TaskCountSummaryDto {
  final int? total;
  final int? active;
  final int? completed;
  final int? urgent;
  final int? daily;
  final int? progress;

  const TaskCountSummaryDto({
    required this.total,
    required this.active,
    required this.completed,
    required this.urgent,
    required this.daily,
    required this.progress,
  });

  factory TaskCountSummaryDto.fromJson(Map<String, dynamic> json) {
    return TaskCountSummaryDto(
      total: (json['total'] as num?)?.toInt(),
      active: (json['active'] as num?)?.toInt(),
      completed: (json['completed'] as num?)?.toInt(),
      urgent: (json['urgent'] as num?)?.toInt(),
      daily: (json['daily'] as num?)?.toInt(),
      progress: (json['progress'] as num?)?.toInt(),
    );
  }
}
