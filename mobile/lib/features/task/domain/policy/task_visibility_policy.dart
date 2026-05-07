import 'package:lifeos_mobile/features/task/domain/enum/task_mode.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_recurrence_type.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_status.dart';

import '../entities/task.dart';

class TaskVisibilityPolicy {
  const TaskVisibilityPolicy();

  bool isInbox(Task task) {
    return !task.archived &&
        !task.paused &&
        !task.status.isDone &&
        task.dueDate == null &&
        task.dueDateTime == null &&
        task.linkedScheduleBlockId == null &&
        !task.recurrenceType.isRecurring;
  }

  bool isCompleted(Task task) {
    return !task.archived && task.status.isDone;
  }

  bool completedOn(Task task, DateTime day) {
    final achievedDate = task.achievedDate ?? task.completedAt;
    if (achievedDate == null) return false;

    return achievedDate.year == day.year &&
        achievedDate.month == day.month &&
        achievedDate.day == day.day;
  }

  bool isHistory(Task task, DateTime selectedDay) {
    if (!isCompleted(task)) return false;

    final achievedDate = task.achievedDate ?? task.completedAt;
    if (achievedDate == null) return true;

    final completedDay = DateTime(
      achievedDate.year,
      achievedDate.month,
      achievedDate.day,
    );

    final day = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

    return completedDay.isBefore(day);
  }

  bool isProgress(Task task) {
    return task.taskMode.isProgress;
  }
}
