class StaySession {
  final String id;
  final String userId;
  final String placeName;
  final String? placeType;
  final String? matchedPlaceSource;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final double? centerLat;
  final double? centerLng;
  final double? confidence;

  const StaySession({
    required this.id,
    required this.userId,
    required this.placeName,
    required this.placeType,
    required this.matchedPlaceSource,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.centerLat,
    required this.centerLng,
    required this.confidence,
  });
}
