class ScheduleOccurrenceResponseDto {
  final String? scheduleBlockId;
  final String? userId;
  final String? title;
  final String? type;
  final String? recurrenceType; // ADDED THIS
  final String? occurrenceDate;
  final String? startDateTime;
  final String? endDateTime;

  const ScheduleOccurrenceResponseDto({
    required this.scheduleBlockId,
    required this.userId,
    required this.title,
    required this.type,
    required this.recurrenceType, // ADDED THIS
    required this.occurrenceDate,
    required this.startDateTime,
    required this.endDateTime,
  });

  factory ScheduleOccurrenceResponseDto.fromJson(Map<String, dynamic> json) {
    return ScheduleOccurrenceResponseDto(
      scheduleBlockId: json['scheduleBlockId'] as String?,
      userId: json['userId'] as String?,
      title: json['title'] as String?,
      type: json['type'] as String?,
      recurrenceType: json['recurrenceType'] as String?, // ADDED THIS
      occurrenceDate: json['occurrenceDate'] as String?,
      startDateTime: json['startDateTime'] as String?,
      endDateTime: json['endDateTime'] as String?,
    );
  }
}
