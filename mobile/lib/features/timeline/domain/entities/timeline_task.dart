class TimelineTask {
  final String id;
  final String title;
  final String status;
  final int progressPercent;
  final String? category;
  final DateTime? dueDate;

  const TimelineTask({
    required this.id,
    required this.title,
    required this.status,
    required this.progressPercent,
    required this.category,
    required this.dueDate,
  });
}
