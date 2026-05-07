import '../../domain/model/stay_session.dart';
import '../dto/stay_session_response_dto.dart';

class StaySessionMapper {
  const StaySessionMapper();

  StaySession toDomain(StaySessionResponseDto dto) {
    return StaySession(
      id: dto.id ?? '',
      userId: dto.userId ?? '',
      placeName: dto.placeName ?? 'Unknown Place',
      placeType: dto.placeType,
      matchedPlaceSource: dto.matchedPlaceSource,
      startTime: DateTime.tryParse(dto.startTime ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(dto.endTime ?? '') ?? DateTime.now(),
      durationMinutes: dto.durationMinutes ?? 0,
      centerLat: dto.centerLat,
      centerLng: dto.centerLng,
      confidence: dto.confidence,
    );
  }
}
