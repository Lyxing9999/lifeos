import '../../../task/domain/enum/task_status.dart';

class TimelineTaskLite {
  final String id;
  final String title;
  final TaskStatus status;
  final int progressPercent;
  final String? category;
  final DateTime? dueDate;

  const TimelineTaskLite({
    required this.id,
    required this.title,
    required this.status,
    required this.progressPercent,
    required this.category,
    required this.dueDate,
  });
}
