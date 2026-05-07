class TodayPlaceInsightResponseDto {
  final String? placeName;
  final String? placeType;
  final int? durationMinutes;
  final String? source;

  const TodayPlaceInsightResponseDto({
    required this.placeName,
    required this.placeType,
    required this.durationMinutes,
    required this.source,
  });

  factory TodayPlaceInsightResponseDto.fromJson(Map<String, dynamic> json) {
    return TodayPlaceInsightResponseDto(
      placeName: json['placeName'] as String?,
      placeType: json['placeType'] as String?,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      source: json['source'] as String?,
    );
  }
}
