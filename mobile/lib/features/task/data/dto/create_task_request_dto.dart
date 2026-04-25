class CreateTaskRequestDto {
  final String userId;
  final String title;
  final String? description;
  final String? category;
  final String? taskMode;
  final String? priority;
  final String? dueDate;
  final String? dueDateTime;
  final int? progressPercent;
  final String? recurrenceType;
  final String? recurrenceStartDate;
  final String? recurrenceEndDate;
  final String? recurrenceDaysOfWeek;
  final String? linkedScheduleBlockId;
  final List<String>? tags;

  const CreateTaskRequestDto({
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.taskMode,
    required this.priority,
    required this.dueDate,
    required this.dueDateTime,
    required this.progressPercent,
    required this.recurrenceType,
    required this.recurrenceStartDate,
    required this.recurrenceEndDate,
    required this.recurrenceDaysOfWeek,
    required this.linkedScheduleBlockId,
    required this.tags,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'taskMode': taskMode,
      'priority': priority,
      'dueDate': dueDate,
      'dueDateTime': dueDateTime,
      'progressPercent': progressPercent,
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
