class ScheduleBlockResponseDto {
  final String? id;
  final String? userId;
  final String? title;
  final String? type;
  final String? description;
  final String? startTime;
  final String? endTime;
  final String? recurrenceType;
  final Object? recurrenceDaysOfWeek;
  final String? recurrenceStartDate;
  final String? recurrenceEndDate;
  final bool? active;

  const ScheduleBlockResponseDto({
    required this.id,
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
    required this.active,
  });

  factory ScheduleBlockResponseDto.fromJson(Map<String, dynamic> json) {
    return ScheduleBlockResponseDto(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      title: json['title'] as String?,
      type: json['type'] as String?,
      description: json['description'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      recurrenceType: json['recurrenceType'] as String?,
      recurrenceDaysOfWeek: json['recurrenceDaysOfWeek'] ?? json['daysOfWeek'],
      recurrenceStartDate:
          (json['recurrenceStartDate'] ?? json['activeFromDate']) as String?,
      recurrenceEndDate:
          (json['recurrenceEndDate'] ?? json['activeToDate']) as String?,
      active: json['active'] as bool?,
    );
  }
}
