import '../model/daily_score.dart';

abstract class ScoreRepository {
  Future<DailyScore> getDailyScore({required DateTime date});

  Future<DailyScore> generateDailyScore({required DateTime date});

  Future<void> deleteDailyScore({required DateTime date});
}
