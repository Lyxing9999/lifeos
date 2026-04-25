import '../model/daily_score.dart';

abstract class ScoreRepository {
  Future<DailyScore> getDailyScore({
    required String userId,
    required DateTime date,
  });

  Future<DailyScore> generateDailyScore({
    required String userId,
    required DateTime date,
  });

  Future<void> deleteDailyScore({
    required String userId,
    required DateTime date,
  });
}
