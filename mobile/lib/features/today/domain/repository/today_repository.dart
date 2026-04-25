import '../model/today_overview.dart';

abstract class TodayRepository {
  Future<TodayOverview> getToday({
    required String userId,
    required DateTime date,
  });
}
