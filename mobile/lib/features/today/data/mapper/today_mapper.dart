import '../../../schedule/domain/enum/schedule_block_type.dart';
import '../../../score/data/dto/score_response_dto.dart';
import '../../../score/data/mapper/score_mapper.dart';
import '../../../summary/data/dto/summary_response_dto.dart';
import '../../../summary/data/mapper/summary_mapper.dart';
import '../../../task/data/dto/task_response_dto.dart';
import '../../../task/data/mapper/task_mapper.dart';
import '../../../timeline/data/dto/timeline_day_response_dto.dart';
import '../../../timeline/data/mapper/timeline_mapper.dart';
import '../../domain/model/today_current_schedule.dart';
import '../../domain/model/today_financial_insight.dart';
import '../../domain/model/today_overview.dart';
import '../../domain/model/today_place_insight.dart';
import '../dto/today_current_schedule_response_dto.dart';
import '../dto/today_financial_insight_response_dto.dart';
import '../dto/today_place_insight_response_dto.dart';
import '../dto/today_response_dto.dart';

class TodayMapper {
  final SummaryMapper summaryMapper;
  final ScoreMapper scoreMapper;
  final TimelineMapper timelineMapper;
  final TaskMapper taskMapper;

  const TodayMapper({
    required this.summaryMapper,
    required this.scoreMapper,
    required this.timelineMapper,
    required this.taskMapper,
  });

  TodayOverview toDomain(TodayResponseDto dto) {
    final user = dto.user ?? const <String, dynamic>{};

    return TodayOverview(
      userId: user['id'] as String? ?? '',
      userName: user['name'] as String? ?? '',
      userEmail: user['email'] as String? ?? '',
      timezone: user['timezone'] as String? ?? '',
      locale: user['locale'] as String? ?? '',
      date: DateTime.tryParse(dto.date ?? '') ?? DateTime.now(),
      summary: dto.summary == null
          ? null
          : summaryMapper.toDomain(SummaryResponseDto.fromJson(dto.summary!)),
      score: dto.score == null
          ? null
          : scoreMapper.toDomain(ScoreResponseDto.fromJson(dto.score!)),
      timeline: dto.timeline == null
          ? null
          : timelineMapper.toDayDomain(
              TimelineDayResponseDto.fromJson(dto.timeline!),
            ),
      currentScheduleBlock: dto.currentScheduleBlock == null
          ? null
          : _mapCurrentSchedule(
              TodayCurrentScheduleResponseDto.fromJson(
                dto.currentScheduleBlock!,
              ),
            ),
      topActiveTask: dto.topActiveTask == null
          ? null
          : taskMapper.toDomain(TaskResponseDto.fromJson(dto.topActiveTask!)),
      topPlaceInsight: dto.topPlaceInsight == null
          ? null
          : _mapPlaceInsight(
              TodayPlaceInsightResponseDto.fromJson(dto.topPlaceInsight!),
            ),
      financialInsight: dto.financialInsight == null
          ? null
          : _mapFinancialInsight(
              TodayFinancialInsightResponseDto.fromJson(dto.financialInsight!),
            ),
    );
  }

  TodayCurrentSchedule _mapCurrentSchedule(
    TodayCurrentScheduleResponseDto dto,
  ) {
    final start = DateTime.tryParse(dto.startDateTime ?? '') ?? DateTime.now();
    final end = DateTime.tryParse(dto.endDateTime ?? '') ?? DateTime.now();

    return TodayCurrentSchedule(
      scheduleBlockId: dto.scheduleBlockId ?? '',
      title: dto.title ?? '',
      type: ScheduleBlockTypeX.fromApi(dto.type ?? 'OTHER'),
      startDateTime: start,
      endDateTime: end,
      activeNow: dto.activeNow ?? false,
    );
  }

  TodayPlaceInsight _mapPlaceInsight(TodayPlaceInsightResponseDto dto) {
    return TodayPlaceInsight(
      placeName: dto.placeName ?? '',
      placeType: dto.placeType ?? '',
      durationMinutes: dto.durationMinutes ?? 0,
      source: dto.source ?? '',
    );
  }

  TodayFinancialInsight _mapFinancialInsight(
    TodayFinancialInsightResponseDto dto,
  ) {
    return TodayFinancialInsight(
      totalEvents: dto.totalEvents ?? 0,
      totalOutgoingAmount: dto.totalOutgoingAmount ?? 0,
      latestMerchantName: dto.latestMerchantName ?? '',
      latestAmount: dto.latestAmount ?? 0,
      latestCurrency: dto.latestCurrency ?? '',
    );
  }
}
