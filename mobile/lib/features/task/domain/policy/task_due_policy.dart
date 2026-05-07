import '../entities/task.dart';

class TaskDuePolicy {
  const TaskDuePolicy();

  bool isDueToday(Task task, DateTime day) {
    final date = task.dueDateTime ?? task.dueDate;
    if (date == null) return false;

    return date.year == day.year &&
        date.month == day.month &&
        date.day == day.day;
  }

  bool isOverdue(Task task, DateTime day) {
    if (!task.isActive) {
      return false;
    }
    final date = task.dueDateTime ?? task.dueDate;
    if (date == null) return false;

    final currentDay = DateTime(day.year, day.month, day.day);
    final dueDay = DateTime(date.year, date.month, date.day);

    return dueDay.isBefore(currentDay);
  }
}
