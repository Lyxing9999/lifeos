import '../../../../core/time/api_date_formatter.dart';
import '../../domain/command/create_task_command.dart';
import '../../domain/enum/task_mode.dart';
import '../../domain/enum/task_priority.dart';
import '../../domain/enum/task_recurrence_type.dart';

class CreateTaskRequestDto {
  final String? userId;
  final String title;
  final String? description;
  final String? category;
  final String taskMode;
  final String priority;
  final String? dueDate;
  final String? dueDateTime;
  final int? progressPercent;
  final String recurrenceType;
  final String? recurrenceStartDate;
  final String? recurrenceEndDate;

  /// Backend expects comma-separated String:
  /// "MONDAY,WEDNESDAY"
  final String? recurrenceDaysOfWeek;

  final String? linkedScheduleBlockId;
  final Set<String> tags;

  const CreateTaskRequestDto({
    this.userId,
    required this.title,
    this.description,
    this.category,
    required this.taskMode,
    required this.priority,
    this.dueDate,
    this.dueDateTime,
    this.progressPercent,
    required this.recurrenceType,
    this.recurrenceStartDate,
    this.recurrenceEndDate,
    this.recurrenceDaysOfWeek,
    this.linkedScheduleBlockId,
    this.tags = const {},
  });

  factory CreateTaskRequestDto.fromCommand(
    CreateTaskCommand command, {
    required ApiDateFormatter dateFormatter,
    String? userId,
  }) {
    return CreateTaskRequestDto(
      userId: _blankToNull(userId),
      title: command.title.trim(),
      description: _blankToNull(command.description),
      category: _blankToNull(command.category),
      taskMode: command.taskMode.apiValue,
      priority: command.priority.apiValue,
      dueDate: dateFormatter.formatNullableDate(command.dueDate),
      dueDateTime: dateFormatter.formatNullableDateTime(command.dueDateTime),
      progressPercent: command.progressPercent,
      recurrenceType: command.recurrenceType.apiValue,
      recurrenceStartDate: dateFormatter.formatNullableDate(
        command.recurrenceStartDate,
      ),
      recurrenceEndDate: dateFormatter.formatNullableDate(
        command.recurrenceEndDate,
      ),
      recurrenceDaysOfWeek: _daysToApi(command.recurrenceDaysOfWeek),
      linkedScheduleBlockId: _blankToNull(command.linkedScheduleBlockId),
      tags: _normalizeTags(command.tags),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'userId': userId,
      'title': title,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      'taskMode': taskMode,
      'priority': priority,
      if (dueDate != null) 'dueDate': dueDate,
      if (dueDateTime != null) 'dueDateTime': dueDateTime,
      if (progressPercent != null) 'progressPercent': progressPercent,
      'recurrenceType': recurrenceType,
      if (recurrenceStartDate != null)
        'recurrenceStartDate': recurrenceStartDate,
      if (recurrenceEndDate != null) 'recurrenceEndDate': recurrenceEndDate,
      if (recurrenceDaysOfWeek != null)
        'recurrenceDaysOfWeek': recurrenceDaysOfWeek,
      if (linkedScheduleBlockId != null)
        'linkedScheduleBlockId': linkedScheduleBlockId,
      if (tags.isNotEmpty) 'tags': tags.toList(),
    };
  }

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  static Set<String> _normalizeTags(List<String> tags) {
    return tags.map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toSet();
  }

  static String? _daysToApi(List<String> days) {
    final normalized = days
        .map((day) => day.trim().toUpperCase())
        .where((day) => day.isNotEmpty)
        .toSet()
        .toList();

    if (normalized.isEmpty) return null;
    return normalized.join(',');
  }
}
