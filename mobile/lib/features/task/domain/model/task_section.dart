import 'task.dart';

class TaskSection {
  final List<Task> urgentTasks;
  final List<Task> dailyTasks;
  final List<Task> progressTasks;
  final List<Task> standardTasks;

  const TaskSection({
    required this.urgentTasks,
    required this.dailyTasks,
    required this.progressTasks,
    required this.standardTasks,
  });

  const TaskSection.empty()
    : urgentTasks = const [],
      dailyTasks = const [],
      progressTasks = const [],
      standardTasks = const [];

  bool get isEmpty =>
      urgentTasks.isEmpty &&
      dailyTasks.isEmpty &&
      progressTasks.isEmpty &&
      standardTasks.isEmpty;
}
