class LocationBatchIngestResponseDto {
  final int? requestedPoints;
  final int? acceptedPoints;
  final int? rejectedPoints;
  final String? message;

  const LocationBatchIngestResponseDto({
    required this.requestedPoints,
    required this.acceptedPoints,
    required this.rejectedPoints,
    required this.message,
  });

  factory LocationBatchIngestResponseDto.fromJson(Map<String, dynamic> json) {
    return LocationBatchIngestResponseDto(
      requestedPoints: (json['requestedPoints'] as num?)?.toInt(),
      acceptedPoints: (json['acceptedPoints'] as num?)?.toInt(),
      rejectedPoints: (json['rejectedPoints'] as num?)?.toInt(),
      message: json['message'] as String?,
    );
  }
}
