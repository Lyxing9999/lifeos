import '../../domain/enum/place_type.dart';
import '../../domain/model/place.dart';
import '../../domain/repository/place_repository.dart';
import '../datasource/place_remote_datasource.dart';
import '../dto/create_place_request_dto.dart';
import '../dto/update_place_request_dto.dart';
import '../mapper/place_mapper.dart';

class PlaceRepositoryImpl implements PlaceRepository {
  final PlaceRemoteDataSource remoteDataSource;
  final PlaceMapper mapper;

  const PlaceRepositoryImpl({
    required this.remoteDataSource,
    required this.mapper,
  });

  @override
  Future<List<Place>> getPlacesByUser(String userId) async {
    final dtos = await remoteDataSource.getPlacesByUser(userId);
    return dtos.map(mapper.toDomain).toList();
  }

  @override
  Future<Place> getPlaceById(String id) async {
    final dto = await remoteDataSource.getPlaceById(id);
    return mapper.toDomain(dto);
  }

  @override
  Future<Place> createPlace({
    required String userId,
    required String name,
    required PlaceType placeType,
    required double latitude,
    required double longitude,
    required double matchRadiusMeters,
  }) async {
    final dto = await remoteDataSource.createPlace(
      CreatePlaceRequestDto(
        userId: userId,
        name: name,
        placeType: placeType.apiValue,
        latitude: latitude,
        longitude: longitude,
        matchRadiusMeters: matchRadiusMeters,
      ),
    );

    return mapper.toDomain(dto);
  }

  @override
  Future<Place> updatePlace({
    required String id,
    required String name,
    required PlaceType placeType,
    required double latitude,
    required double longitude,
    required double matchRadiusMeters,
    bool? active,
  }) async {
    final dto = await remoteDataSource.updatePlace(
      id: id,
      request: UpdatePlaceRequestDto(
        name: name,
        placeType: placeType.apiValue,
        latitude: latitude,
        longitude: longitude,
        matchRadiusMeters: matchRadiusMeters,
        active: active,
      ),
    );

    return mapper.toDomain(dto);
  }

  @override
  Future<void> deletePlace(String id) async {
    await remoteDataSource.deletePlace(id);
  }
}
