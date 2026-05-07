import 'package:lifeos_mobile/features/task/domain/enum/task_mode.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_priority.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_recurrence_type.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_status.dart';
import 'package:lifeos_mobile/features/task/domain/entities/task.dart';

class TaskTestData {
  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static Task inboxTask({
    String id = 'inbox-1',
    String title = 'Buy shoes',
    TaskStatus status = TaskStatus.todo,
  }) {
    return Task(
      id: id,
      userId: 'user-1',
      title: title,
      description: null,
      category: 'Personal',
      status: status,
      taskMode: TaskMode.standard,
      priority: TaskPriority.medium,
      dueDate: null,
      dueDateTime: null,
      progressPercent: 0,
      startedAt: null,
      completedAt: status.isDone ? DateTime.now() : null,
      archived: false,
      paused: false,
      recurrenceType: TaskRecurrenceType.none,
      recurrenceStartDate: null,
      recurrenceEndDate: null,
      recurrenceDaysOfWeek: const [],
      linkedScheduleBlockId: null,
      tags: const [],
    );
  }

  static Task dueTodayTask({
    String id = 'today-1',
    String title = 'Pay rent',
    TaskStatus status = TaskStatus.todo,
  }) {
    final date = today();

    return Task(
      id: id,
      userId: 'user-1',
      title: title,
      description: null,
      category: 'Finance',
      status: status,
      taskMode: TaskMode.urgent,
      priority: TaskPriority.high,
      dueDate: date,
      dueDateTime: null,
      progressPercent: 0,
      startedAt: null,
      completedAt: status.isDone ? DateTime.now() : null,
      archived: false,
      paused: false,
      recurrenceType: TaskRecurrenceType.none,
      recurrenceStartDate: null,
      recurrenceEndDate: null,
      recurrenceDaysOfWeek: const [],
      linkedScheduleBlockId: null,
      tags: const [],
    );
  }

  static Task progressTask({
    String id = 'progress-1',
    String title = 'Build dashboard',
    int progress = 40,
    DateTime? dueDate,
    TaskStatus status = TaskStatus.todo,
  }) {
    return Task(
      id: id,
      userId: 'user-1',
      title: title,
      description: null,
      category: 'Work',
      status: status,
      taskMode: TaskMode.progress,
      priority: TaskPriority.high,
      dueDate: dueDate,
      dueDateTime: null,
      progressPercent: progress,
      startedAt: null,
      completedAt: status.isDone ? DateTime.now() : null,
      archived: false,
      paused: false,
      recurrenceType: TaskRecurrenceType.none,
      recurrenceStartDate: null,
      recurrenceEndDate: null,
      recurrenceDaysOfWeek: const [],
      linkedScheduleBlockId: null,
      tags: const [],
    );
  }

  static Task recurringDailyTask({
    String id = 'daily-1',
    String title = 'Go to Gym',
    TaskStatus status = TaskStatus.todo,
  }) {
    final date = today();

    return Task(
      id: id,
      userId: 'user-1',
      title: title,
      description: null,
      category: 'Health',
      status: status,
      taskMode: TaskMode.daily,
      priority: TaskPriority.medium,
      dueDate: null,
      dueDateTime: null,
      progressPercent: 0,
      startedAt: null,
      completedAt: status.isDone ? DateTime.now() : null,
      archived: false,
      paused: false,
      recurrenceType: TaskRecurrenceType.daily,
      recurrenceStartDate: date,
      recurrenceEndDate: null,
      recurrenceDaysOfWeek: const [],
      linkedScheduleBlockId: null,
      tags: const [],
    );
  }

  static Task archivedTask({
    String id = 'archived-1',
    String title = 'Old task',
  }) {
    return Task(
      id: id,
      userId: 'user-1',
      title: title,
      description: null,
      category: 'Other',
      status: TaskStatus.todo,
      taskMode: TaskMode.standard,
      priority: TaskPriority.low,
      dueDate: null,
      dueDateTime: null,
      progressPercent: 0,
      startedAt: null,
      completedAt: null,
      archived: true,
      paused: false,
      recurrenceType: TaskRecurrenceType.none,
      recurrenceStartDate: null,
      recurrenceEndDate: null,
      recurrenceDaysOfWeek: const [],
      linkedScheduleBlockId: null,
      tags: const [],
    );
  }
}
