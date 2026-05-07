import '../enum/task_filter.dart';
import 'task.dart';
import 'task_count_summary.dart';

class TaskSurfaceOverview {
  final DateTime date;
  final String filter;

  final List<Task> dueTasks;
  final List<Task> inboxTasks;
  final List<Task> doneTasks;
  final List<Task> historyTasks;
  final List<Task> pausedTasks;
  final List<Task> archivedTasks;
  final List<Task> allTasks;

  final TaskCountSummary dueCounts;
  final TaskCountSummary inboxCounts;
  final TaskCountSummary doneCounts;
  final TaskCountSummary historyCounts;
  final TaskCountSummary pausedCounts;
  final TaskCountSummary archivedCounts;
  final TaskCountSummary allCounts;

  const TaskSurfaceOverview({
    required this.date,
    required this.filter,
    required this.dueTasks,
    required this.inboxTasks,
    required this.doneTasks,
    required this.historyTasks,
    required this.pausedTasks,
    required this.archivedTasks,
    required this.allTasks,
    required this.dueCounts,
    required this.inboxCounts,
    required this.doneCounts,
    required this.historyCounts,
    required this.pausedCounts,
    required this.archivedCounts,
    required this.allCounts,
  });

  factory TaskSurfaceOverview.empty(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    return TaskSurfaceOverview(
      date: normalizedDate,
      filter: 'ACTIVE',
      dueTasks: const [],
      inboxTasks: const [],
      doneTasks: const [],
      historyTasks: const [],
      pausedTasks: const [],
      archivedTasks: const [],
      allTasks: const [],
      dueCounts: const TaskCountSummary.empty(),
      inboxCounts: const TaskCountSummary.empty(),
      doneCounts: const TaskCountSummary.empty(),
      historyCounts: const TaskCountSummary.empty(),
      pausedCounts: const TaskCountSummary.empty(),
      archivedCounts: const TaskCountSummary.empty(),
      allCounts: const TaskCountSummary.empty(),
    );
  }

  List<Task> tasksFor(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.due:
        return dueTasks;
      case TaskFilter.inbox:
        return inboxTasks;
      case TaskFilter.done:
        return doneTasks;
      case TaskFilter.all:
        return allTasks;
      case TaskFilter.paused:
        return pausedTasks;
      case TaskFilter.history:
        return historyTasks;
      case TaskFilter.archive:
        return archivedTasks;
    }
  }

  TaskCountSummary countsFor(TaskFilter filter) {
    final tasks = tasksFor(filter);

    switch (filter) {
      case TaskFilter.due:
        return dueCounts.copyWith(total: tasks.length, active: tasks.length);

      case TaskFilter.inbox:
        return inboxCounts.copyWith(total: tasks.length, active: tasks.length);

      case TaskFilter.done:
        return doneCounts.copyWith(
          total: tasks.length,
          completed: tasks.length,
        );

      case TaskFilter.all:
        return allCounts.copyWith(total: tasks.length, active: tasks.length);

      case TaskFilter.paused:
        return pausedCounts.copyWith(total: tasks.length);

      case TaskFilter.history:
        return historyCounts.copyWith(
          total: tasks.length,
          completed: tasks.length,
        );

      case TaskFilter.archive:
        return archivedCounts.copyWith(total: tasks.length);
    }
  }

  bool get isEmpty {
    return dueTasks.isEmpty &&
        inboxTasks.isEmpty &&
        doneTasks.isEmpty &&
        historyTasks.isEmpty &&
        pausedTasks.isEmpty &&
        archivedTasks.isEmpty &&
        allTasks.isEmpty;
  }

  TaskSurfaceOverview copyWith({
    DateTime? date,
    String? filter,
    List<Task>? dueTasks,
    List<Task>? inboxTasks,
    List<Task>? doneTasks,
    List<Task>? historyTasks,
    List<Task>? pausedTasks,
    List<Task>? archivedTasks,
    List<Task>? allTasks,
    TaskCountSummary? dueCounts,
    TaskCountSummary? inboxCounts,
    TaskCountSummary? doneCounts,
    TaskCountSummary? historyCounts,
    TaskCountSummary? pausedCounts,
    TaskCountSummary? archivedCounts,
    TaskCountSummary? allCounts,
  }) {
    return TaskSurfaceOverview(
      date: date ?? this.date,
      filter: filter ?? this.filter,
      dueTasks: dueTasks ?? this.dueTasks,
      inboxTasks: inboxTasks ?? this.inboxTasks,
      doneTasks: doneTasks ?? this.doneTasks,
      historyTasks: historyTasks ?? this.historyTasks,
      pausedTasks: pausedTasks ?? this.pausedTasks,
      archivedTasks: archivedTasks ?? this.archivedTasks,
      allTasks: allTasks ?? this.allTasks,
      dueCounts: dueCounts ?? this.dueCounts,
      inboxCounts: inboxCounts ?? this.inboxCounts,
      doneCounts: doneCounts ?? this.doneCounts,
      historyCounts: historyCounts ?? this.historyCounts,
      pausedCounts: pausedCounts ?? this.pausedCounts,
      archivedCounts: archivedCounts ?? this.archivedCounts,
      allCounts: allCounts ?? this.allCounts,
    );
  }
}
