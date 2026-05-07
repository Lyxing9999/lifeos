import '../../../domain/enum/task_mode.dart';
import '../../../domain/enum/task_priority.dart';
import '../../../domain/enum/task_recurrence_type.dart';

class TaskFormController {
  Future<void> Function()? _submit;

  Future<void> submit() async {
    await _submit?.call();
  }

  void bind(Future<void> Function() submit) {
    _submit = submit;
  }

  void unbind(Future<void> Function() submit) {
    if (_submit == submit) {
      _submit = null;
    }
  }
}

class TaskFormInput {
  final String title;
  final String? description;
  final String? category;

  final TaskMode taskMode;
  final TaskPriority priority;

  /// One-time planning model.
  final DateTime? dueDate;
  final DateTime? dueDateTime;
  final bool clearDueDate;
  final bool clearDueDateTime;

  /// Recurring planning model.
  final TaskRecurrenceType recurrenceType;
  final DateTime? recurrenceStartDate;
  final DateTime? recurrenceEndDate;
  final List<String> recurrenceDaysOfWeek;
  final bool clearRecurrence;

  final int? progressPercent;
  final List<String> tags;

  final String? linkedScheduleBlockId;
  final bool clearLinkedScheduleBlock;

  const TaskFormInput({
    required this.title,
    required this.description,
    required this.category,
    required this.taskMode,
    required this.priority,
    required this.dueDate,
    required this.dueDateTime,
    required this.clearDueDate,
    required this.clearDueDateTime,
    required this.recurrenceType,
    required this.recurrenceStartDate,
    required this.recurrenceEndDate,
    required this.recurrenceDaysOfWeek,
    required this.clearRecurrence,
    required this.progressPercent,
    required this.tags,
    required this.linkedScheduleBlockId,
    required this.clearLinkedScheduleBlock,
  });

  bool get isRecurring => recurrenceType.isRecurring;

  bool get isOneTimeDueTask {
    return dueDate != null || dueDateTime != null;
  }
}
