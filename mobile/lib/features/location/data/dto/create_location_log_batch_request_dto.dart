class CreateLocationLogBatchRequestDto {
  final String userId;
  final List<CreateLocationLogPointDto> points;

  const CreateLocationLogBatchRequestDto({
    required this.userId,
    required this.points,
  });

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'points': points.map((e) => e.toJson()).toList()};
  }
}

class CreateLocationLogPointDto {
  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final double? speedMetersPerSecond;
  final String recordedAt;
  final String? source;

  const CreateLocationLogPointDto({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.speedMetersPerSecond,
    required this.recordedAt,
    required this.source,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'accuracyMeters': accuracyMeters,
      'speedMetersPerSecond': speedMetersPerSecond,
      'recordedAt': recordedAt,
      'source': source,
    };
    map.removeWhere((_, value) => value == null);
    return map;
  }
}
