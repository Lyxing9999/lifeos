class LocationLogResponseDto {
  final String? id;
  final String? userId;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final double? speedMetersPerSecond;
  final String? recordedAt;
  final String? source;

  const LocationLogResponseDto({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.speedMetersPerSecond,
    required this.recordedAt,
    required this.source,
  });

  factory LocationLogResponseDto.fromJson(Map<String, dynamic> json) {
    return LocationLogResponseDto(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      accuracyMeters: (json['accuracyMeters'] as num?)?.toDouble(),
      speedMetersPerSecond: (json['speedMetersPerSecond'] as num?)?.toDouble(),
      recordedAt: json['recordedAt'] as String?,
      source: json['source'] as String?,
    );
  }
}
