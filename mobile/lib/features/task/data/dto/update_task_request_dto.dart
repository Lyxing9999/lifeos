class UpdateTaskRequestDto {
  final String? title;
  final String? description;
  final String? category;
  final String? status;
  final String? taskMode;
  final String? priority;
  final String? dueDate;
  final String? dueDateTime;
  final int? progressPercent;
  final bool? archived;
  final String? recurrenceType;
  final String? recurrenceStartDate;
  final String? recurrenceEndDate;
  final String? recurrenceDaysOfWeek;
  final String? linkedScheduleBlockId;
  final List<String>? tags;

  const UpdateTaskRequestDto({
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.taskMode,
    required this.priority,
    required this.dueDate,
    required this.dueDateTime,
    required this.progressPercent,
    required this.archived,
    required this.recurrenceType,
    required this.recurrenceStartDate,
    required this.recurrenceEndDate,
    required this.recurrenceDaysOfWeek,
    required this.linkedScheduleBlockId,
    required this.tags,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'taskMode': taskMode,
      'priority': priority,
      'dueDate': dueDate,
      'dueDateTime': dueDateTime,
      'progressPercent': progressPercent,
      'archived': archived,
      'recurrenceType': recurrenceType,
      'recurrenceStartDate': recurrenceStartDate,
      'recurrenceEndDate': recurrenceEndDate,
      'recurrenceDaysOfWeek': recurrenceDaysOfWeek,
      'linkedScheduleBlockId': linkedScheduleBlockId,
      'tags': tags,
    };
    map.removeWhere((_, value) => value == null);
    return map;
  }
}
