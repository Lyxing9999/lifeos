import '../command/create_task_command.dart';
import '../command/update_task_command.dart';
import '../enum/task_mode.dart';
import '../enum/task_recurrence_type.dart';

class TaskValidationPolicy {
  const TaskValidationPolicy();

  String? validateCreate(CreateTaskCommand command) {
    final titleError = validateTitle(command.title);
    if (titleError != null) return titleError;

    return _validateRules(
      taskMode: command.taskMode,
      progressPercent: command.progressPercent,
      recurrenceType: command.recurrenceType,
      recurrenceStartDate: command.recurrenceStartDate,
      recurrenceEndDate: command.recurrenceEndDate,
      recurrenceDaysOfWeek: command.recurrenceDaysOfWeek,
    );
  }

  String? validateUpdate(UpdateTaskCommand command) {
    if (command.title != null) {
      final titleError = validateTitle(command.title!);
      if (titleError != null) return titleError;
    }

    return _validateRules(
      taskMode: command.taskMode,
      progressPercent: command.progressPercent,
      recurrenceType: command.recurrenceType,
      recurrenceStartDate: command.recurrenceStartDate,
      recurrenceEndDate: command.recurrenceEndDate,
      recurrenceDaysOfWeek: command.recurrenceDaysOfWeek,
    );
  }

  String? validateTitle(String title) {
    if (title.trim().isEmpty) {
      return 'Task title is required';
    }

    return null;
  }

  String? _validateRules({
    required TaskMode? taskMode,
    required int? progressPercent,
    required TaskRecurrenceType? recurrenceType,
    required DateTime? recurrenceStartDate,
    required DateTime? recurrenceEndDate,
    required List<String>? recurrenceDaysOfWeek,
  }) {
    if (progressPercent != null) {
      if (taskMode != TaskMode.progress) {
        return 'Progress percent is only allowed for progress tasks';
      }

      if (progressPercent < 0 || progressPercent > 100) {
        return 'Progress percent must be between 0 and 100';
      }
    }

    if (taskMode == TaskMode.progress &&
        (recurrenceType ?? TaskRecurrenceType.none).isRecurring) {
      return 'Progress tasks represent a finite milestone to 100% and cannot be recurring. Use a Daily task instead.';
    }

    final type = recurrenceType ?? TaskRecurrenceType.none;

    if (type.isRecurring && recurrenceStartDate == null) {
      return 'Recurrence start date is required';
    }

    if (recurrenceStartDate != null &&
        recurrenceEndDate != null &&
        recurrenceEndDate.isBefore(recurrenceStartDate)) {
      return 'Recurrence end date must be on or after start date';
    }

    if (type == TaskRecurrenceType.customWeekly &&
        (recurrenceDaysOfWeek == null || recurrenceDaysOfWeek.isEmpty)) {
      return 'Choose at least one weekday';
    }

    return null;
  }
}
