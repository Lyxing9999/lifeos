import 'location_log_response_dto.dart';

class LocationRangeResponseDto {
  final String? userId;
  final String? startDate;
  final String? endDate;
  final int? totalLogs;
  final List<LocationLogResponseDto> logs;

  const LocationRangeResponseDto({
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.totalLogs,
    required this.logs,
  });

  factory LocationRangeResponseDto.fromJson(Map<String, dynamic> json) {
    return LocationRangeResponseDto(
      userId: json['userId'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      totalLogs: (json['totalLogs'] as num?)?.toInt(),
      logs: (json['logs'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                LocationLogResponseDto.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
