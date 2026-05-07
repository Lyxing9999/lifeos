import '../entities/timeline_day.dart';

abstract class TimelineRepository {
  Future<TimelineDay> getDay({required DateTime date});
}
