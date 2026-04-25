class TimelineStaySession {
  final String id;
  final String userId;
  final String? placeId;
  final String placeName;
  final String? placeType;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final double? centerLatitude;
  final double? centerLongitude;
  final double? confidence;
  final String? placeResolutionStatus;
  final String? matchedPlaceSource;
  final double? placeConfidence;

  const TimelineStaySession({
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
}
