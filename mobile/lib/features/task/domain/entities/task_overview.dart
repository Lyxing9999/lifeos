import 'task.dart';
import 'task_count_summary.dart';
import 'task_section.dart';

class TaskOverview {
  final DateTime date;

  final Task? currentTask;
  final Task? currentUrgentTask;
  final Task? currentDailyTask;
  final Task? currentProgressTask;

  final TaskSection todaySections;
  final TaskSection last3DaySections;
  final TaskSection last7DaySections;
  final TaskSection last30DaySections;

  final TaskCountSummary todayCounts;
  final TaskCountSummary last3DayCounts;
  final TaskCountSummary last7DayCounts;
  final TaskCountSummary last30DayCounts;

  final TaskCountSummary anytimeCounts;
  final List<Task> anytimePreviewTasks;

  final List<Task> recentCompletedTasks;

  const TaskOverview({
    required this.date,
    required this.currentTask,
    required this.currentUrgentTask,
    required this.currentDailyTask,
    required this.currentProgressTask,
    required this.todaySections,
    required this.last3DaySections,
    required this.last7DaySections,
    required this.last30DaySections,
    required this.todayCounts,
    required this.last3DayCounts,
    required this.last7DayCounts,
    required this.last30DayCounts,
    required this.anytimeCounts,
    required this.anytimePreviewTasks,
    required this.recentCompletedTasks,
  });
}
