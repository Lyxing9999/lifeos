class TimelineScheduleOccurrenceResponseDto {
  final String? scheduleBlockId;
  final String? userId;
  final String? title;
  final String? type;
  final String? occurrenceDate;
  final String? startDateTime;
  final String? endDateTime;

  const TimelineScheduleOccurrenceResponseDto({
    required this.scheduleBlockId,
    required this.userId,
    required this.title,
    required this.type,
    required this.occurrenceDate,
    required this.startDateTime,
    required this.endDateTime,
  });

  factory TimelineScheduleOccurrenceResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return TimelineScheduleOccurrenceResponseDto(
      scheduleBlockId: json['scheduleBlockId'] as String?,
      userId: json['userId'] as String?,
      title: json['title'] as String?,
      type: json['type'] as String?,
      occurrenceDate: json['occurrenceDate'] as String?,
      startDateTime: json['startDateTime'] as String?,
      endDateTime: json['endDateTime'] as String?,
    );
  }
}
