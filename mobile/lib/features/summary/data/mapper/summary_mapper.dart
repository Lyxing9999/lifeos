import '../../domain/model/daily_summary.dart';
import '../dto/summary_response_dto.dart';

class SummaryMapper {
  const SummaryMapper();

  DailySummary toDomain(SummaryResponseDto dto) {
    return DailySummary(
      id: dto.id ?? '',
      userId: dto.userId ?? '',
      summaryDate: DateTime.tryParse(dto.summaryDate ?? '') ?? DateTime.now(),
      summaryText: dto.summaryText ?? '',
      topPlaceName: dto.topPlaceName ?? '',
      totalTasks: dto.totalTasks ?? 0,
      completedTasks: dto.completedTasks ?? 0,
      totalPlannedBlocks: dto.totalPlannedBlocks ?? 0,
      totalStaySessions: dto.totalStaySessions ?? 0,
      scoreExplanationText: dto.scoreExplanationText,
      optionalInsight: dto.optionalInsight,
    );
  }
}
