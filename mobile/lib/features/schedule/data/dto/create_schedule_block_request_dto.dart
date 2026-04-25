class CreateScheduleBlockRequestDto {
  final String userId;
  final String title;
  final String type;
  final String? description;
  final String startTime;
  final String endTime;
  final String? recurrenceType;
  final String? recurrenceDaysOfWeek;
  final String recurrenceStartDate;
  final String? recurrenceEndDate;

  const CreateScheduleBlockRequestDto({
    required this.userId,
    required this.title,
    required this.type,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.recurrenceType,
    required this.recurrenceDaysOfWeek,
    required this.recurrenceStartDate,
    required this.recurrenceEndDate,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'userId': userId,
      'title': title,
      'type': type,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'recurrenceType': recurrenceType,
      'recurrenceDaysOfWeek': recurrenceDaysOfWeek,
      'recurrenceStartDate': recurrenceStartDate,
      'recurrenceEndDate': recurrenceEndDate,
    };
    map.removeWhere((_, value) => value == null);
    return map;
  }
}
