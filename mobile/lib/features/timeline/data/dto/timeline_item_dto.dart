class TimelineItemResponseDto {
  final String? itemType;
  final String? itemId;
  final String? title;
  final String? subtitle;
  final String? startDateTime;
  final String? endDateTime;
  final String? badge;
  final String? status;

  const TimelineItemResponseDto({
    required this.itemType,
    required this.itemId,
    required this.title,
    required this.subtitle,
    required this.startDateTime,
    required this.endDateTime,
    required this.badge,
    required this.status,
  });

  factory TimelineItemResponseDto.fromJson(Map<String, dynamic> json) {
    return TimelineItemResponseDto(
      itemType: json['itemType'] as String?,
      itemId: json['itemId'] as String?,
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      startDateTime: json['startDateTime'] as String?,
      endDateTime: json['endDateTime'] as String?,
      badge: json['badge'] as String?,
      status: json['status'] as String?,
    );
  }
}
