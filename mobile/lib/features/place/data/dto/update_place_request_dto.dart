class UpdatePlaceRequestDto {
  final String name;
  final String placeType;
  final double latitude;
  final double longitude;
  final double matchRadiusMeters;
  final bool? active;

  const UpdatePlaceRequestDto({
    required this.name,
    required this.placeType,
    required this.latitude,
    required this.longitude,
    required this.matchRadiusMeters,
    required this.active,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'placeType': placeType,
      'latitude': latitude,
      'longitude': longitude,
      'matchRadiusMeters': matchRadiusMeters,
      'active': active,
    };
    map.removeWhere((_, value) => value == null);
    return map;
  }
}
