class CreateLocationLogRequestDto {
  final String userId;
  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final double? speedMetersPerSecond;
  final String recordedAt;
  final String? source;

  const CreateLocationLogRequestDto({
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.speedMetersPerSecond,
    required this.recordedAt,
    required this.source,
  });
}
