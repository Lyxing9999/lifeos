import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos_mobile/core/enums/loading_status.dart';
import 'package:lifeos_mobile/features/task/application/task_notifier.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_filter.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_status.dart';
import 'package:lifeos_mobile/features/task/domain/entities/task_count_summary.dart';
import 'package:lifeos_mobile/features/task/domain/entities/task_surface.dart';
import 'package:lifeos_mobile/features/task/domain/policy/task_validation_policy.dart';

import '../../../helpers/fake_task_repository.dart';
import '../../../helpers/task_test_data.dart';

void main() {
  group('TaskNotifier', () {
    test('loadTasks success updates tasks and status success', () async {
      final repository = FakeTaskRepository()
        ..tasks = [TaskTestData.inboxTask(title: 'Buy shoes')];

      final notifier = TaskNotifier(repository, const TaskValidationPolicy());

      await notifier.loadTasks(filter: TaskFilter.due);

      expect(notifier.state.status, LoadingStatus.success);
      expect(notifier.state.tasks.length, 1);
      expect(notifier.state.tasks.first.title, 'Buy shoes');
      expect(notifier.state.errorMessage, isNull);
    });

    test('loadTasks error sets status error', () async {
      final repository = FakeTaskRepository()
        ..throwError(Exception('Network failed'));

      final notifier = TaskNotifier(repository, const TaskValidationPolicy());

      await notifier.loadTasks(filter: TaskFilter.due);

      expect(notifier.state.status, LoadingStatus.error);
      expect(notifier.state.tasks, isEmpty);
      expect(notifier.state.errorMessage, isNotNull);
    });

    test(
      'loadSurfaces success stores surfaces and visible today tasks',
      () async {
        final today = TaskTestData.today();
        final dueToday = TaskTestData.dueTodayTask(title: 'Pay rent');
        final inbox = TaskTestData.inboxTask(title: 'Buy shoes');

        final surfaces = TaskSurfaceOverview(
          date: today,
          filter: 'ACTIVE',
          dueTasks: [dueToday],
          inboxTasks: [inbox],
          doneTasks: const [],
          historyTasks: const [],
          pausedTasks: const [],
          archivedTasks: const [],
          allTasks: [dueToday, inbox],
          dueCounts: const TaskCountSummary(
            total: 1,
            active: 1,
            completed: 0,
            urgent: 1,
            daily: 0,
            progress: 0,
          ),
          inboxCounts: const TaskCountSummary(
            total: 1,
            active: 1,
            completed: 0,
            urgent: 0,
            daily: 0,
            progress: 0,
          ),
          doneCounts: const TaskCountSummary.empty(),
          historyCounts: const TaskCountSummary.empty(),
          pausedCounts: const TaskCountSummary.empty(),
          archivedCounts: const TaskCountSummary.empty(),
          allCounts: const TaskCountSummary(
            total: 2,
            active: 2,
            completed: 0,
            urgent: 1,
            daily: 0,
            progress: 0,
          ),
        );

        final repository = FakeTaskRepository()..surfaces = surfaces;
        final notifier = TaskNotifier(repository, const TaskValidationPolicy());

        await notifier.loadSurfaces(date: today, filter: TaskFilter.due);

        expect(notifier.state.status, LoadingStatus.success);
        expect(notifier.state.surfaces, isNotNull);
        expect(notifier.state.tasks.length, 1);
        expect(notifier.state.tasks.first.title, 'Pay rent');
        expect(notifier.state.surfaces!.inboxTasks.first.title, 'Buy shoes');
      },
    );

    test('completeTask success stores selectedTask completed', () async {
      final completedTask = TaskTestData.dueTodayTask(
        title: 'Pay rent',
        status: TaskStatus.completed,
      );

      final repository = FakeTaskRepository()..selectedTask = completedTask;

      final notifier = TaskNotifier(repository, const TaskValidationPolicy());

      await notifier.completeTask(
        taskId: completedTask.id,
        date: TaskTestData.today(),
      );

      expect(notifier.state.mutationStatus, LoadingStatus.success);
      expect(notifier.state.selectedTask, isNotNull);
      expect(notifier.state.selectedTask!.status, TaskStatus.completed);
      expect(notifier.state.successMessage, isNotNull);
    });

    test('archiveTask success clears selectedTask', () async {
      final repository = FakeTaskRepository();
      final notifier = TaskNotifier(repository, const TaskValidationPolicy());

      await notifier.archiveTask(taskId: 'task-1');

      expect(notifier.state.mutationStatus, LoadingStatus.success);
      expect(notifier.state.selectedTask, isNull);
      expect(notifier.state.successMessage, isNotNull);
    });
  });
}
