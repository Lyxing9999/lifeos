import '../enum/task_mode.dart';
import '../enum/task_priority.dart';
import '../enum/task_recurrence_type.dart';
import '../enum/task_status.dart';

class UpdateTaskCommand {
  final String? title;
  final String? description;
  final String? category;

  final TaskMode? taskMode;
  final TaskPriority? priority;
  final TaskStatus? status;

  final DateTime? dueDate;
  final DateTime? dueDateTime;

  final bool? clearDueDate;
  final bool? clearDueDateTime;

  final int? progressPercent;
  final bool? archived;

  final TaskRecurrenceType? recurrenceType;
  final DateTime? recurrenceStartDate;
  final DateTime? recurrenceEndDate;
  final List<String>? recurrenceDaysOfWeek;

  final String? linkedScheduleBlockId;
  final List<String>? tags;
  final bool? clearLinkedScheduleBlock;
  final bool? clearRecurrence;
  
  const UpdateTaskCommand({
    this.title,
    this.description,
    this.category,
    this.taskMode,
    this.priority,
    this.status,
    this.dueDate,
    this.dueDateTime,
    this.clearDueDate,
    this.clearDueDateTime,
    this.progressPercent,
    this.archived,
    this.recurrenceType,
    this.recurrenceStartDate,
    this.recurrenceEndDate,
    this.recurrenceDaysOfWeek,
    this.linkedScheduleBlockId,
    this.tags,
    this.clearLinkedScheduleBlock,
    this.clearRecurrence,
  });
}
