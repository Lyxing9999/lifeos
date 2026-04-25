class TaskCountSummary {
  final int total;
  final int active;
  final int completed;
  final int urgent;
  final int daily;
  final int progress;

  const TaskCountSummary({
    required this.total,
    required this.active,
    required this.completed,
    required this.urgent,
    required this.daily,
    required this.progress,
  });

  const TaskCountSummary.empty()
    : total = 0,
      active = 0,
      completed = 0,
      urgent = 0,
      daily = 0,
      progress = 0;
}
