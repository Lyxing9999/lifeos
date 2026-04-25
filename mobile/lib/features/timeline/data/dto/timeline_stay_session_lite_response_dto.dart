class TimelineStaySessionLiteResponseDto {
  final String? id;
  final String? userId;
  final String? placeId;
  final String? placeName;
  final String? placeType;
  final String? startTime;
  final String? endTime;
  final int? durationMinutes;
  final double? centerLatitude;
  final double? centerLongitude;
  final double? confidence;
  final String? placeResolutionStatus;
  final String? matchedPlaceSource;
  final double? placeConfidence;

  const TimelineStaySessionLiteResponseDto({
    required this.id,
    required this.userId,
    required this.placeId,
    required this.placeName,
    required this.placeType,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.confidence,
    required this.placeResolutionStatus,
    required this.matchedPlaceSource,
    required this.placeConfidence,
  });

  factory TimelineStaySessionLiteResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return TimelineStaySessionLiteResponseDto(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      placeId: json['placeId'] as String?,
      placeName: json['placeName'] as String?,
      placeType: json['placeType'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      centerLatitude: (json['centerLatitude'] as num?)?.toDouble(),
      centerLongitude: (json['centerLongitude'] as num?)?.toDouble(),
      confidence: (json['confidence'] as num?)?.toDouble(),
      placeResolutionStatus: json['placeResolutionStatus'] as String?,
      matchedPlaceSource: json['matchedPlaceSource'] as String?,
      placeConfidence: (json['placeConfidence'] as num?)?.toDouble(),
    );
  }
}
