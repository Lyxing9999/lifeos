class CreatePlaceRequestDto {
  final String userId;
  final String name;
  final String placeType;
  final double latitude;
  final double longitude;
  final double matchRadiusMeters;

  const CreatePlaceRequestDto({
    required this.userId,
    required this.name,
    required this.placeType,
    required this.latitude,
    required this.longitude,
    required this.matchRadiusMeters,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'placeType': placeType,
      'latitude': latitude,
      'longitude': longitude,
      'matchRadiusMeters': matchRadiusMeters,
    };
  }
}
