import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_recurrence_type.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_status.dart';
import 'package:lifeos_mobile/features/task/domain/entities/task.dart';

import '../../../helpers/task_test_data.dart';

enum TaskSurface { inbox, activeToday, doneToday, hidden, archived }

TaskSurface resolveTaskSurface(Task task, DateTime selectedDate) {
  if (task.archived) {
    return TaskSurface.archived;
  }

  final isCompleted = task.status.isDone;
  final isNoDate = task.dueDate == null && task.dueDateTime == null;
  final isNotRecurring = !task.recurrenceType.isRecurring;

  if (isNoDate && isNotRecurring) {
    return isCompleted ? TaskSurface.hidden : TaskSurface.inbox;
  }

  final dueDate = task.dueDateTime ?? task.dueDate;
  final dueDay = dueDate == null
      ? null
      : DateTime(dueDate.year, dueDate.month, dueDate.day);

  final selectedDay = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
  );

  final relevantToday =
      dueDay != null && dueDay.isAtSameMomentAs(selectedDay) ||
      task.recurrenceType != TaskRecurrenceType.none;

  if (!relevantToday) {
    return TaskSurface.hidden;
  }

  return isCompleted ? TaskSurface.doneToday : TaskSurface.activeToday;
}

void main() {
  group('Task lifecycle surface rules', () {
    test('no-due active task belongs to Inbox', () {
      final task = TaskTestData.inboxTask();

      final surface = resolveTaskSurface(task, TaskTestData.today());

      expect(surface, TaskSurface.inbox);
    });

    test('no-due completed task leaves Inbox and goes hidden/history', () {
      final task = TaskTestData.inboxTask(status: TaskStatus.completed);

      final surface = resolveTaskSurface(task, TaskTestData.today());

      expect(surface, TaskSurface.hidden);
    });

    test('due today active task belongs to Active Today', () {
      final task = TaskTestData.dueTodayTask();

      final surface = resolveTaskSurface(task, TaskTestData.today());

      expect(surface, TaskSurface.activeToday);
    });

    test('due today completed task belongs to Done Today', () {
      final task = TaskTestData.dueTodayTask(status: TaskStatus.completed);

      final surface = resolveTaskSurface(task, TaskTestData.today());

      expect(surface, TaskSurface.doneToday);
    });

    test('progress no-due active task belongs to Inbox', () {
      final task = TaskTestData.progressTask();

      final surface = resolveTaskSurface(task, TaskTestData.today());

      expect(surface, TaskSurface.inbox);
    });

    test('progress due today active task belongs to Active Today', () {
      final task = TaskTestData.progressTask(dueDate: TaskTestData.today());

      final surface = resolveTaskSurface(task, TaskTestData.today());

      expect(surface, TaskSurface.activeToday);
    });

    test('recurring active task belongs to Active Today', () {
      final task = TaskTestData.recurringDailyTask();

      final surface = resolveTaskSurface(task, TaskTestData.today());

      expect(surface, TaskSurface.activeToday);
    });

    test('archived task belongs to Archive', () {
      final task = TaskTestData.archivedTask();

      final surface = resolveTaskSurface(task, TaskTestData.today());

      expect(surface, TaskSurface.archived);
    });
  });
}
