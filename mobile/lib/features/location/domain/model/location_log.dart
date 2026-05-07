class LocationLog {
  final String id;
  final String userId;
  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final double? speedMetersPerSecond;
  final String? source;
  final DateTime recordedAt;

  const LocationLog({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.speedMetersPerSecond,
    required this.source,
    required this.recordedAt,
  });
}
