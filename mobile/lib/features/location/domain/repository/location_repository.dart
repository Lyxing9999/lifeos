import '../model/location_log.dart';

abstract class LocationRepository {
  Future<List<LocationLog>> getByUserAndDay({
    required String userId,
    required DateTime date,
  });

  Future<LocationBatchIngestResult> createBatch({
    required String userId,
    required List<LocationLogCreateInput> logs,
  });
}

class LocationLogCreateInput {
  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final double? speedMetersPerSecond;
  final String? source;
  final DateTime recordedAt;

  const LocationLogCreateInput({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.speedMetersPerSecond,
    required this.source,
    required this.recordedAt,
  });
}

class LocationBatchIngestResult {
  final int requestedPoints;
  final int acceptedPoints;
  final int rejectedPoints;
  final String? message;

  const LocationBatchIngestResult({
    required this.requestedPoints,
    required this.acceptedPoints,
    required this.rejectedPoints,
    required this.message,
  });
}
