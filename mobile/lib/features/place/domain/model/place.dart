import '../enum/place_type.dart';

class Place {
  final String id;
  final String userId;
  final String name;
  final PlaceType placeType;
  final double latitude;
  final double longitude;
  final double matchRadiusMeters;
  final bool active;

  const Place({
    required this.id,
    required this.userId,
    required this.name,
    required this.placeType,
    required this.latitude,
    required this.longitude,
    required this.matchRadiusMeters,
    required this.active,
  });
}
