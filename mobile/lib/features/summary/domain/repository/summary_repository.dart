import '../model/daily_summary.dart';

abstract class SummaryRepository {
  Future<DailySummary> getDailySummary({required DateTime date});

  Future<DailySummary> generateDailySummary({required DateTime date});

  Future<void> deleteDailySummary({required DateTime date});
}
