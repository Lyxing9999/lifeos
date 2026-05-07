import '../../domain/enum/place_type.dart';
import '../../domain/model/place.dart';
import '../dto/place_response_dto.dart';

class PlaceMapper {
  const PlaceMapper();

  Place toDomain(PlaceResponseDto dto) {
    return Place(
      id: dto.id ?? '',
      userId: dto.userId ?? '',
      name: dto.name ?? '',
      placeType: PlaceTypeX.fromApi(dto.placeType ?? 'OTHER'),
      latitude: dto.latitude ?? 0,
      longitude: dto.longitude ?? 0,
      matchRadiusMeters: dto.matchRadiusMeters ?? 50,
      active: dto.active ?? true,
    );
  }
}
