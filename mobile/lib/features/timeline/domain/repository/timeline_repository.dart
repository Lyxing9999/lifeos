import '../model/timeline_day.dart';

abstract class TimelineRepository {
  Future<TimelineDay> getDay({required String userId, required DateTime date});
}
