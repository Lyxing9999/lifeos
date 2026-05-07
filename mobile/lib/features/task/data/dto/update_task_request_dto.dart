import 'package:lifeos_mobile/features/task/domain/enum/task_status.dart';

import '../../../../core/time/api_date_formatter.dart';
import '../../domain/command/update_task_command.dart';
import '../../domain/enum/task_mode.dart';
import '../../domain/enum/task_priority.dart';
import '../../domain/enum/task_recurrence_type.dart';

class UpdateTaskRequestDto {
  final String? title;
  final String? description;
  final String? category;
  final String? taskMode;
  final String? priority;
  final String? status;
  final String? dueDate;
  final String? dueDateTime;
  final int? progressPercent;
  final bool? archived;
  final String? recurrenceType;
  final String? recurrenceStartDate;
  final String? recurrenceEndDate;

  final bool? clearRecurrence;
  final bool? clearLinkedScheduleBlock;
  final bool? clearDueDate;
  final bool? clearDueDateTime;

  /// Backend expects comma-separated String:
  /// "MONDAY,WEDNESDAY"
  final String? recurrenceDaysOfWeek;

  final String? linkedScheduleBlockId;
  final Set<String>? tags;

  const UpdateTaskRequestDto({
    this.title,
    this.description,
    this.category,
    this.taskMode,
    this.priority,
    this.status,
    this.dueDate,
    this.dueDateTime,
    this.progressPercent,
    this.archived,
    this.recurrenceType,
    this.recurrenceStartDate,
    this.recurrenceEndDate,
    this.recurrenceDaysOfWeek,
    this.linkedScheduleBlockId,
    this.tags,
    this.clearRecurrence,
    this.clearLinkedScheduleBlock,
    this.clearDueDate,
    this.clearDueDateTime,
  });

  factory UpdateTaskRequestDto.fromCommand(
    UpdateTaskCommand command, {
    required ApiDateFormatter dateFormatter,
  }) {
    return UpdateTaskRequestDto(
      title: _blankToNull(command.title),
      description: _blankToNull(command.description),
      category: _blankToNull(command.category),
      taskMode: command.taskMode?.apiValue,
      priority: command.priority?.apiValue,
      status: command.status?.apiValue,
      dueDate: dateFormatter.formatNullableDate(command.dueDate),
      dueDateTime: dateFormatter.formatNullableDateTime(command.dueDateTime),
      progressPercent: command.progressPercent,
      archived: command.archived,
      recurrenceType: command.recurrenceType?.apiValue,
      recurrenceStartDate: dateFormatter.formatNullableDate(
        command.recurrenceStartDate,
      ),
      recurrenceEndDate: dateFormatter.formatNullableDate(
        command.recurrenceEndDate,
      ),
      recurrenceDaysOfWeek: command.recurrenceDaysOfWeek == null
          ? null
          : _daysToApi(command.recurrenceDaysOfWeek!),
      linkedScheduleBlockId: _blankToNull(command.linkedScheduleBlockId),
      tags: command.tags == null ? null : _normalizeTags(command.tags!),
      clearRecurrence: command.clearRecurrence,
      clearLinkedScheduleBlock: command.clearLinkedScheduleBlock,
      clearDueDate: command.clearDueDate,
      clearDueDateTime: command.clearDueDateTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (taskMode != null) 'taskMode': taskMode,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (dueDate != null) 'dueDate': dueDate,
      if (dueDateTime != null) 'dueDateTime': dueDateTime,
      if (progressPercent != null) 'progressPercent': progressPercent,
      if (archived != null) 'archived': archived,
      if (recurrenceType != null) 'recurrenceType': recurrenceType,
      if (recurrenceStartDate != null)
        'recurrenceStartDate': recurrenceStartDate,
      if (recurrenceEndDate != null) 'recurrenceEndDate': recurrenceEndDate,
      if (recurrenceDaysOfWeek != null)
        'recurrenceDaysOfWeek': recurrenceDaysOfWeek,
      if (linkedScheduleBlockId != null)
        'linkedScheduleBlockId': linkedScheduleBlockId,
      if (tags != null) 'tags': tags!.toList(),
      if (clearRecurrence != null) 'clearRecurrence': clearRecurrence,
      if (clearLinkedScheduleBlock != null)
        'clearLinkedScheduleBlock': clearLinkedScheduleBlock,
      if (clearDueDate != null) 'clearDueDate': clearDueDate,
      if (clearDueDateTime != null) 'clearDueDateTime': clearDueDateTime,
    
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
