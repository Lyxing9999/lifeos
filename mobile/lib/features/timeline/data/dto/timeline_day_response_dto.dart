import 'timeline_item_dto.dart';
import 'timeline_schedule_lite_response_dto.dart';
import 'timeline_stay_session_lite_response_dto.dart';
import 'timeline_summary_response_dto.dart';
import 'timeline_task_lite_response_dto.dart';
// import 'timeline_financial_event_response_dto.dart';
// import 'timeline_financial_summary_response_dto.dart';

class TimelineDayResponseDto {
  final String? userId;
  final String? date;
  final TimelineSummaryResponseDto? summary;
  final List<TimelineItemResponseDto> items;
  final List<TimelineTaskLiteResponseDto> tasks;
  final List<TimelineScheduleLiteResponseDto> schedules;
  final List<TimelineStaySessionLiteResponseDto> staySessions;

  // final TimelineFinancialSummaryResponseDto? financialSummary;
  // final List<TimelineFinancialEventResponseDto> financialEvents;

  const TimelineDayResponseDto({
    required this.userId,
    required this.date,
    required this.summary,
    required this.items,
    required this.tasks,
    required this.schedules,
    required this.staySessions,
    // required this.financialSummary,
    // required this.financialEvents,
  });

  factory TimelineDayResponseDto.fromJson(Map<String, dynamic> json) {
    return TimelineDayResponseDto(
      userId: json['userId'] as String?,
      date: json['date'] as String?,
      summary: json['summary'] == null
          ? null
          : TimelineSummaryResponseDto.fromJson(
              json['summary'] as Map<String, dynamic>,
            ),
      items: (json['items'] as List<dynamic>? ?? [])
          .map(
            (e) => TimelineItemResponseDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      tasks: (json['tasks'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                TimelineTaskLiteResponseDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      schedules: (json['schedules'] as List<dynamic>? ?? [])
          .map(
            (e) => TimelineScheduleLiteResponseDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      staySessions: (json['staySessions'] as List<dynamic>? ?? [])
          .map(
            (e) => TimelineStaySessionLiteResponseDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),

      // -- Skipped --
      // financialSummary: json['financialSummary'] == null ? null : TimelineFinancialSummaryResponseDto.fromJson(...),
      // financialEvents: ...
    );
  }
}
