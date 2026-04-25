import '../model/daily_summary.dart';

abstract class SummaryRepository {
  Future<DailySummary> getDailySummary({
    required String userId,
    required DateTime date,
  });

  Future<DailySummary> generateDailySummary({
    required String userId,
    required DateTime date,
  });

  Future<void> deleteDailySummary({
    required String userId,
    required DateTime date,
  });
}
