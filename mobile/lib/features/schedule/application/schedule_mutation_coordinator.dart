import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../timeline/application/timeline_providers.dart';
import '../../today/application/today_providers.dart';
import '../domain/command/create_schedule_block_command.dart';
import '../domain/command/update_schedule_block_command.dart';
import 'schedule_providers.dart';

class ScheduleMutationCoordinator {
  final Ref ref;

  const ScheduleMutationCoordinator(this.ref);

  Future<void> create(CreateScheduleBlockCommand command) async {
    await ref.read(scheduleNotifierProvider.notifier).create(command);
    await _refreshAfterMutation();
  }

  Future<void> update({
    required String id,
    required UpdateScheduleBlockCommand command,
  }) async {
    await ref
        .read(scheduleNotifierProvider.notifier)
        .updateBlock(id: id, command: command);
    await _refreshAfterMutation();
  }

  Future<void> deactivate({required String id}) async {
    await ref
        .read(scheduleNotifierProvider.notifier)
        .deactivateSchedule(scheduleId: id);
    await _refreshAfterMutation();
  }

  Future<void> activate({required String id}) async {
    await ref
        .read(scheduleNotifierProvider.notifier)
        .activateSchedule(scheduleId: id);
    await _refreshAfterMutation();
  }

  Future<void> delete({required String id}) async {
    await ref
        .read(scheduleNotifierProvider.notifier)
        .deleteSchedule(scheduleId: id);
    await _refreshAfterMutation();
  }

  Future<void> _refreshAfterMutation() async {
    final todayDate = ref.read(todayNotifierProvider).selectedDate;

    // THE FIX: Remove the 'filter' parameter.
    // loadSurfaces now fetches the full surface (active + inactive) in one call.
    await ref
        .read(scheduleNotifierProvider.notifier)
        .loadSurfaces(
          date: DateTime.now(), // Blueprint is evaluated against today
          isRefresh: true,
        );

    // Refresh cross-domain dependencies silently
    ref.read(todayNotifierProvider.notifier).load(date: todayDate);
    ref.read(timelineNotifierProvider.notifier).loadDay(date: todayDate);
    ref.invalidate(scheduleSelectOptionsProvider);
  }
}
