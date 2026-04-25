import 'task_tag_dto.dart';

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
  final String? recurrenceType;
  final String? recurrenceStartDate;
  final String? recurrenceEndDate;
  final List<String>? recurrenceDaysOfWeek;
  final String? linkedScheduleBlockId;
  final List<TaskTagDto>? tags;

  const TaskResponseDto({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.taskMode,
    required this.priority,
    required this.dueDate,
    required this.dueDateTime,
    required this.progressPercent,
    required this.startedAt,
    required this.completedAt,
    required this.archived,
    required this.recurrenceType,
    required this.recurrenceStartDate,
    required this.recurrenceEndDate,
    required this.recurrenceDaysOfWeek,
    required this.linkedScheduleBlockId,
    required this.tags,
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
      progressPercent: (json['progressPercent'] as num?)?.toInt(),
      startedAt: json['startedAt'] as String?,
      completedAt: json['completedAt'] as String?,
      archived: json['archived'] as bool?,
      recurrenceType: json['recurrenceType'] as String?,
      recurrenceStartDate: json['recurrenceStartDate'] as String?,
      recurrenceEndDate: json['recurrenceEndDate'] as String?,
      recurrenceDaysOfWeek: _parseRecurrenceDays(json['recurrenceDaysOfWeek']),
      linkedScheduleBlockId: json['linkedScheduleBlockId'] as String?,
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((item) => TaskTagDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static List<String>? _parseRecurrenceDays(dynamic raw) {
    if (raw == null) return null;
    if (raw is List) {
      return raw.map((item) => item.toString()).toList();
    }
    if (raw is String && raw.trim().isNotEmpty) {
      return raw
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList();
    }
    return null;
  }
}
