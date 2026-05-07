class TodayCurrentScheduleResponseDto {
  final String? scheduleBlockId;
  final String? title;
  final String? type;
  final String? startDateTime;
  final String? endDateTime;
  final bool? activeNow;

  const TodayCurrentScheduleResponseDto({
    required this.scheduleBlockId,
    required this.title,
    required this.type,
    required this.startDateTime,
    required this.endDateTime,
    required this.activeNow,
  });

  factory TodayCurrentScheduleResponseDto.fromJson(Map<String, dynamic> json) {
    return TodayCurrentScheduleResponseDto(
      scheduleBlockId: json['scheduleBlockId'] as String?,
      title: json['title'] as String?,
      type: json['type'] as String?,
      startDateTime: json['startDateTime'] as String?,
      endDateTime: json['endDateTime'] as String?,
      activeNow: json['activeNow'] as bool?,
    );
  }
}
