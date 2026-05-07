class PlaceResponseDto {
  final String? id;
  final String? userId;
  final String? name;
  final String? placeType;
  final double? latitude;
  final double? longitude;
  final double? matchRadiusMeters;
  final bool? active;

  const PlaceResponseDto({
    required this.id,
    required this.userId,
    required this.name,
    required this.placeType,
    required this.latitude,
    required this.longitude,
    required this.matchRadiusMeters,
    required this.active,
  });

  factory PlaceResponseDto.fromJson(Map<String, dynamic> json) {
    return PlaceResponseDto(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      name: json['name'] as String?,
      placeType: json['placeType'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      matchRadiusMeters: (json['matchRadiusMeters'] as num?)?.toDouble(),
      active: json['active'] as bool?,
    );
  }
}
