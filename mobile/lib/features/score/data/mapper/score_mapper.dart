import '../../domain/model/daily_score.dart';
import '../dto/score_response_dto.dart';

class ScoreMapper {
  const ScoreMapper();

  DailyScore toDomain(ScoreResponseDto dto) {
    return DailyScore(
      id: dto.id ?? '',
      userId: dto.userId ?? '',
      scoreDate: DateTime.tryParse(dto.scoreDate ?? '') ?? DateTime.now(),
      completionScore: dto.completionScore ?? 0,
      structureScore: dto.structureScore ?? 0,
      overallScore: dto.overallScore ?? 0,
      completedTasks: dto.completedTasks ?? 0,
      totalTasks: dto.totalTasks ?? 0,
      totalPlannedBlocks: dto.totalPlannedBlocks ?? 0,
      totalStaySessions: dto.totalStaySessions ?? 0,
      scoreExplanation: dto.scoreExplanation,
    );
  }
}
