class UpdateScheduleBlockRequestDto {
  final String? title;
  final String? type;
  final String? description;
  final String? startTime;
  final String? endTime;
  final String? recurrenceType;
  final String? recurrenceDaysOfWeek;
  final String recurrenceStartDate;
  final String? recurrenceEndDate;
  final bool? active;

  const UpdateScheduleBlockRequestDto({
    required this.title,
    required this.type,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.recurrenceType,
    required this.recurrenceDaysOfWeek,
    required this.recurrenceStartDate,
    required this.recurrenceEndDate,
    required this.active,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'type': type,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'recurrenceType': recurrenceType,
      'recurrenceDaysOfWeek': recurrenceDaysOfWeek,
      'recurrenceStartDate': recurrenceStartDate,
      'recurrenceEndDate': recurrenceEndDate,
      'active': active,
    };
    map.removeWhere((_, value) => value == null);
    return map;
  }
}
