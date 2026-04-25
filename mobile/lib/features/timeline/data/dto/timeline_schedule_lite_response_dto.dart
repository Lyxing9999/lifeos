class TimelineScheduleLiteResponseDto {
  final String? scheduleBlockId;
  final String? userId;
  final String? title;
  final String? type;
  final String? occurrenceDate;
  final String? startDateTime;
  final String? endDateTime;

  const TimelineScheduleLiteResponseDto({
    required this.scheduleBlockId,
    required this.userId,
    required this.title,
    required this.type,
    required this.occurrenceDate,
    required this.startDateTime,
    required this.endDateTime,
  });

  factory TimelineScheduleLiteResponseDto.fromJson(Map<String, dynamic> json) {
    return TimelineScheduleLiteResponseDto(
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
