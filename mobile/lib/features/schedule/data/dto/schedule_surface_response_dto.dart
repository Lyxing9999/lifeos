import 'schedule_block_response_dto.dart';
import 'schedule_count_summary_response_dto.dart';

class ScheduleSurfaceResponseDto {
  final String? date;
  final List<ScheduleBlockResponseDto> activeBlocks;
  final List<ScheduleBlockResponseDto> inactiveBlocks;
  final ScheduleCountSummaryResponseDto? counts;
  final List<ScheduleBlockResponseDto>? historyBlocks;
  const ScheduleSurfaceResponseDto({
    required this.date,
    required this.activeBlocks,
    required this.inactiveBlocks,
    required this.counts,
    this.historyBlocks = const [],
  });

  factory ScheduleSurfaceResponseDto.fromJson(Map<String, dynamic> json) {
    return ScheduleSurfaceResponseDto(
      date: json['date'] as String?,
      activeBlocks: _parseList(json['activeBlocks']),
      inactiveBlocks: _parseList(json['inactiveBlocks']),
      historyBlocks: _parseList(json['historyBlocks']),
      counts: ScheduleCountSummaryResponseDto.fromJson(
        json['counts'] as Map<String, dynamic>?,
      ),
    );
  }

  static List<ScheduleBlockResponseDto> _parseList(Object? raw) {
    return (raw as List<dynamic>? ?? [])
        .map(
          (item) =>
              ScheduleBlockResponseDto.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
