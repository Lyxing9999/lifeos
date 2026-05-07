import '../enum/task_mode.dart';
import '../enum/task_priority.dart';
import '../enum/task_recurrence_type.dart';
class CreateTaskCommand {
  final String title;
  final String? description;
  final String? category;
  final TaskMode taskMode;
  final TaskPriority priority;
  final DateTime? dueDate;
  final DateTime? dueDateTime;
  final int? progressPercent;
  final TaskRecurrenceType recurrenceType;
  final DateTime? recurrenceStartDate;
  final DateTime? recurrenceEndDate;
  final List<String> recurrenceDaysOfWeek;
  final String? linkedScheduleBlockId;
  final List<String> tags;
  const CreateTaskCommand({
    required this.title,
    this.description,
    this.category,
    this.taskMode = TaskMode.standard,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.dueDateTime,
    this.progressPercent,
    this.recurrenceType = TaskRecurrenceType.none,
    this.recurrenceStartDate,
    this.recurrenceEndDate,
    this.recurrenceDaysOfWeek = const [],
    this.linkedScheduleBlockId,
    this.tags = const [],
  });
}
