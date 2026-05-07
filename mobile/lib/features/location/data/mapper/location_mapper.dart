import '../../domain/model/location_log.dart';
import '../dto/location_log_response_dto.dart';

class LocationMapper {
  const LocationMapper();

  LocationLog toDomain(LocationLogResponseDto dto) {
    return LocationLog(
      id: dto.id ?? '',
      userId: dto.userId ?? '',
      latitude: dto.latitude ?? 0,
      longitude: dto.longitude ?? 0,
      accuracyMeters: dto.accuracyMeters,
      speedMetersPerSecond: dto.speedMetersPerSecond,
      source: dto.source,
      recordedAt: DateTime.tryParse(dto.recordedAt ?? '') ?? DateTime.now(),
    );
  }
}
