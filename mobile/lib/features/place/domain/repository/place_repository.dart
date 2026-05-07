import '../enum/place_type.dart';
import '../model/place.dart';

abstract class PlaceRepository {
  Future<List<Place>> getPlacesByUser(String userId);
  Future<Place> getPlaceById(String id);

  Future<Place> createPlace({
    required String userId,
    required String name,
    required PlaceType placeType,
    required double latitude,
    required double longitude,
    required double matchRadiusMeters,
  });

  Future<Place> updatePlace({
    required String id,
    required String name,
    required PlaceType placeType,
    required double latitude,
    required double longitude,
    required double matchRadiusMeters,
    bool? active,
  });

  Future<void> deletePlace(String id);
}
