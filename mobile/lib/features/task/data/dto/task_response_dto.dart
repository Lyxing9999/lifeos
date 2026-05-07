import 'task_tag_response_dto.dart';

class TaskResponseDto {
  final String? id;
  final String? userId;

  final String? title;
  final String? description;
  final String? category;

  final String? status;
  final String? taskMode;
  final String? priority;

  final String? dueDate;
  final String? dueDateTime;

  final int? progressPercent;

  final String? startedAt;
  final String? completedAt;

  final bool? archived;

  final String? achievedDate;
  final String? doneClearedAt;

  final bool? paused;
  final String? pausedAt;

  /// Backend LocalDate.
  final String? pauseUntil;

  final String? recurrenceType;
  final String? recurrenceStartDate;
  final String? recurrenceEndDate;

  /// Backend comma-separated string:
  /// "MONDAY,WEDNESDAY"
  final String? recurrenceDaysOfWeek;

  final String? linkedScheduleBlockId;

  final List<TaskTagResponseDto> tags;

  const TaskResponseDto({
    this.id,
    this.userId,
    this.title,
    this.description,
    this.category,
    this.status,
    this.taskMode,
    this.priority,
    this.dueDate,
    this.dueDateTime,
    this.progressPercent,
    this.startedAt,
    this.completedAt,
    this.archived,
    this.achievedDate,
    this.doneClearedAt,
    this.paused,
    this.pausedAt,
    this.pauseUntil,
    this.recurrenceType,
    this.recurrenceStartDate,
    this.recurrenceEndDate,
    this.recurrenceDaysOfWeek,
    this.linkedScheduleBlockId,
    this.tags = const [],
  });

  factory TaskResponseDto.fromJson(Map<String, dynamic> json) {
    return TaskResponseDto(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      status: json['status'] as String?,
      taskMode: json['taskMode'] as String?,
      priority: json['priority'] as String?,
      dueDate: json['dueDate'] as String?,
      dueDateTime: json['dueDateTime'] as String?,
      progressPercent: _asInt(json['progressPercent']),
      startedAt: json['startedAt'] as String?,
      completedAt: json['completedAt'] as String?,
      archived: json['archived'] as bool?,
      achievedDate: json['achievedDate'] as String?,
      doneClearedAt: json['doneClearedAt'] as String?,
      paused: json['paused'] as bool?,
      pausedAt: json['pausedAt'] as String?,
      pauseUntil: json['pauseUntil'] as String?,
      recurrenceType: json['recurrenceType'] as String?,
      recurrenceStartDate: json['recurrenceStartDate'] as String?,
      recurrenceEndDate: json['recurrenceEndDate'] as String?,
      recurrenceDaysOfWeek: json['recurrenceDaysOfWeek'] as String?,
      linkedScheduleBlockId: json['linkedScheduleBlockId'] as String?,
      tags: _parseTags(json['tags']),
    );
  }

  static int? _asInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static List<TaskTagResponseDto> _parseTags(Object? raw) {
    if (raw == null) return const [];

    if (raw is! List) return const [];

    return raw
        .whereType<Map<String, dynamic>>()
        .map(TaskTagResponseDto.fromJson)
        .toList();
  }
}
