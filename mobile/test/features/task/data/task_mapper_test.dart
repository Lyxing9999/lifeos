import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos_mobile/features/task/data/dto/task_response_dto.dart';
import 'package:lifeos_mobile/features/task/data/mapper/task_mapper.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_mode.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_priority.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_recurrence_type.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_status.dart';

void main() {
  group('TaskMapper', () {
    const mapper = TaskMapper();

    test('maps standard task response to domain task', () {
      final dto = TaskResponseDto.fromJson({
        'id': 'task-1',
        'userId': 'user-1',
        'title': 'Buy shoes',
        'description': 'Running shoes',
        'category': 'Personal',
        'status': 'TODO',
        'taskMode': 'STANDARD',
        'priority': 'MEDIUM',
        'dueDate': null,
        'dueDateTime': null,
        'progressPercent': 0,
        'startedAt': null,
        'completedAt': null,
        'archived': false,
        'recurrenceType': 'NONE',
        'recurrenceStartDate': null,
        'recurrenceEndDate': null,
        'recurrenceDaysOfWeek': null,
        'linkedScheduleBlockId': null,
        'tags': [
          {'name': 'shopping'},
        ],
      });

      final task = mapper.toDomain(dto);

      expect(task.id, 'task-1');
      expect(task.userId, 'user-1');
      expect(task.title, 'Buy shoes');
      expect(task.description, 'Running shoes');
      expect(task.category, 'Personal');
      expect(task.status, TaskStatus.todo);
      expect(task.taskMode, TaskMode.standard);
      expect(task.priority, TaskPriority.medium);
      expect(task.recurrenceType, TaskRecurrenceType.none);
      expect(task.archived, false);
      expect(task.tags.length, 1);
      expect(task.tags.first.name, 'shopping');
    });

    test('maps completed progress task', () {
      final dto = TaskResponseDto.fromJson({
        'id': 'task-2',
        'userId': 'user-1',
        'title': 'Build dashboard',
        'description': null,
        'category': 'Work',
        'status': 'COMPLETED',
        'taskMode': 'PROGRESS',
        'priority': 'HIGH',
        'dueDate': '2026-05-01',
        'dueDateTime': null,
        'progressPercent': 80,
        'startedAt': null,
        'completedAt': '2026-05-01T10:00:00Z',
        'archived': false,
        'recurrenceType': 'NONE',
        'recurrenceStartDate': null,
        'recurrenceEndDate': null,
        'recurrenceDaysOfWeek': null,
        'linkedScheduleBlockId': null,
        'tags': [],
      });

      final task = mapper.toDomain(dto);

      expect(task.title, 'Build dashboard');
      expect(task.status, TaskStatus.completed);
      expect(task.taskMode, TaskMode.progress);
      expect(task.priority, TaskPriority.high);
      expect(task.progressPercent, 80);
      expect(task.dueDate, isNotNull);
      expect(task.completedAt, isNotNull);
    });

    test('maps recurring task', () {
      final dto = TaskResponseDto.fromJson({
        'id': 'task-3',
        'userId': 'user-1',
        'title': 'Go to Gym',
        'description': null,
        'category': 'Health',
        'status': 'TODO',
        'taskMode': 'DAILY',
        'priority': 'MEDIUM',
        'dueDate': null,
        'dueDateTime': null,
        'progressPercent': 0,
        'startedAt': null,
        'completedAt': null,
        'archived': false,
        'recurrenceType': 'DAILY',
        'recurrenceStartDate': '2026-05-01',
        'recurrenceEndDate': null,
        'recurrenceDaysOfWeek': null,
        'linkedScheduleBlockId': null,
        'tags': [],
      });

      final task = mapper.toDomain(dto);

      expect(task.title, 'Go to Gym');
      expect(task.taskMode, TaskMode.daily);
      expect(task.recurrenceType, TaskRecurrenceType.daily);
      expect(task.recurrenceStartDate, isNotNull);
    });
  });
}
