import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/task/application/task_providers.dart';
import '../../features/timeline/application/timeline_providers.dart';
import '../../features/today/application/today_providers.dart';

final refreshCoordinatorProvider = Provider<RefreshCoordinator>((ref) {
  return RefreshCoordinator(ref);
});

class RefreshCoordinator {
  const RefreshCoordinator(this.ref);

  final Ref ref;

  Future<void> afterTaskMutation({
    required DateTime affectedDate,
    bool refreshTaskOverview = true,
    bool refreshToday = true,
    bool refreshTimeline = true,
    bool refreshScheduleSelectOptions = true,
  }) async {
    final day = _localDay(affectedDate);

    final futures = <Future<void>>[];

    if (refreshTaskOverview) {
      futures.add(
        ref.read(taskNotifierProvider.notifier).loadOverview(date: day),
      );
    }

    if (refreshToday) {
      futures.add(ref.read(todayNotifierProvider.notifier).load(date: day));
    }

    if (refreshTimeline) {
      futures.add(
        ref.read(timelineNotifierProvider.notifier).loadDay(date: day),
      );
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }

    if (refreshScheduleSelectOptions) {
      ref.invalidate(taskScheduleSelectOptionsProvider);
    }
  }

  Future<void> afterScheduleMutation({
    required DateTime affectedDate,
    bool refreshTaskOverview = true,
    bool refreshToday = true,
    bool refreshTimeline = true,
    bool refreshScheduleSelectOptions = true,
  }) async {
    final day = _localDay(affectedDate);

    final futures = <Future<void>>[];

    if (refreshTaskOverview) {
      futures.add(
        ref.read(taskNotifierProvider.notifier).loadOverview(date: day),
      );
    }

    if (refreshToday) {
      futures.add(ref.read(todayNotifierProvider.notifier).load(date: day));
    }

    if (refreshTimeline) {
      futures.add(
        ref.read(timelineNotifierProvider.notifier).loadDay(date: day),
      );
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }

    if (refreshScheduleSelectOptions) {
      ref.invalidate(taskScheduleSelectOptionsProvider);
    }
  }

  DateTime _localDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
