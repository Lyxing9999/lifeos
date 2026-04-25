import '../enum/task_mode.dart';
import '../enum/task_priority.dart';
import '../enum/task_recurrence_type.dart';
import '../enum/task_status.dart';
import 'task_tag.dart';

class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? category;
  final TaskStatus status;
  final TaskMode taskMode;
  final TaskPriority priority;
  final DateTime? dueDate;
  final DateTime? dueDateTime;
  final int progressPercent;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final bool archived;
  final TaskRecurrenceType recurrenceType;
  final DateTime? recurrenceStartDate;
  final DateTime? recurrenceEndDate;
  final List<String> recurrenceDaysOfWeek;
  final String? linkedScheduleBlockId;
  final List<TaskTag> tags;

  const Task({
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
}
