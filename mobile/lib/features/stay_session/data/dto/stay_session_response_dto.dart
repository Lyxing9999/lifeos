class StaySessionResponseDto {
  final String? id;
  final String? userId;
  final String? placeName;
  final String? placeType;
  final String? matchedPlaceSource;
  final String? startTime;
  final String? endTime;
  final int? durationMinutes;
  final double? centerLat;
  final double? centerLng;
  final double? confidence;

  const StaySessionResponseDto({
    required this.id,
    required this.userId,
    required this.placeName,
    required this.placeType,
    required this.matchedPlaceSource,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.centerLat,
    required this.centerLng,
    required this.confidence,
  });

  factory StaySessionResponseDto.fromJson(Map<String, dynamic> json) {
    return StaySessionResponseDto(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      placeName: json['placeName'] as String?,
      placeType: json['placeType'] as String?,
      matchedPlaceSource: json['matchedPlaceSource'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      centerLat: (json['centerLat'] as num?)?.toDouble(),
      centerLng: (json['centerLng'] as num?)?.toDouble(),
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }
}
