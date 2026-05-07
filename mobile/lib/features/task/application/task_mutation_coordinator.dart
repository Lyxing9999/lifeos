import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../timeline/application/timeline_providers.dart';
import '../../today/application/today_providers.dart';
import '../domain/command/create_task_command.dart';
import '../domain/command/update_task_command.dart';
import 'task_providers.dart';

class TaskMutationCoordinator {
  final Ref ref;

  const TaskMutationCoordinator(this.ref);

  // 1. THE LOCK: Centralized check to prevent rapid-fire API collisions
  bool get _isSaving => ref.read(taskNotifierProvider).isSaving;

  Future<void> createTask({required CreateTaskCommand command}) async {
    if (_isSaving) return;
    await ref.read(taskNotifierProvider.notifier).createTask(command: command);
    await _refreshAfterMutation();
  }

  Future<void> updateTask({
    required String taskId,
    required UpdateTaskCommand command,
  }) async {
    if (_isSaving) return;
    await ref
        .read(taskNotifierProvider.notifier)
        .updateTask(taskId: taskId, command: command);

    await _refreshAfterMutation();
  }

  Future<void> completeTask({
    required String taskId,
    required DateTime date,
  }) async {
    if (_isSaving) return;
    await ref
        .read(taskNotifierProvider.notifier)
        .completeTask(taskId: taskId, date: date);

    await _refreshAfterMutation(date: date);
  }

  Future<void> reopenTask({
    required String taskId,
    required DateTime date,
  }) async {
    if (_isSaving) return;
    await ref
        .read(taskNotifierProvider.notifier)
        .reopenTask(taskId: taskId, date: date);

    await _refreshAfterMutation(date: date);
  }

  Future<void> clearDoneForDay({required DateTime date}) async {
    if (_isSaving) return;
    await ref.read(taskNotifierProvider.notifier).clearDoneForDay(date: date);
    await _refreshAfterMutation(date: date);
  }

  Future<void> pauseTask({required String taskId, DateTime? until}) async {
    if (_isSaving) return;
    await ref
        .read(taskNotifierProvider.notifier)
        .pauseTask(taskId: taskId, until: until);

    await _refreshAfterMutation();
  }

  Future<void> resumeTask({required String taskId}) async {
    if (_isSaving) return;
    await ref.read(taskNotifierProvider.notifier).resumeTask(taskId: taskId);
    await _refreshAfterMutation();
  }

  Future<void> archiveTask({required String taskId}) async {
    if (_isSaving) return;
    await ref.read(taskNotifierProvider.notifier).archiveTask(taskId: taskId);
    await _refreshAfterMutation();
  }

  Future<void> restoreTask({required String taskId}) async {
    if (_isSaving) return;
    await ref.read(taskNotifierProvider.notifier).restoreTask(taskId: taskId);
    await _refreshAfterMutation();
  }

  Future<void> deleteTask({required String taskId}) async {
    if (_isSaving) return;
    await ref.read(taskNotifierProvider.notifier).deleteTask(taskId: taskId);
    await _refreshAfterMutation();
  }

  Future<void> _refreshAfterMutation({DateTime? date}) async {
    final taskState = ref.read(taskNotifierProvider);
    final selectedDate = _localDay(date ?? taskState.selectedDate);
    final selectedFilter = taskState.selectedFilter;

    await ref
        .read(taskNotifierProvider.notifier)
        .loadSurfaces(
          date: selectedDate,
          filter: selectedFilter,
          isRefresh: true,
        );

    await ref
        .read(taskNotifierProvider.notifier)
        .loadOverview(date: selectedDate);

    await Future.wait([
      _refreshToday(date: selectedDate),
      _refreshTimeline(date: selectedDate),
    ]);

    ref.invalidate(taskScheduleSelectOptionsProvider);
  }

  Future<void> _refreshToday({required DateTime date}) async {
    final todayState = ref.read(todayNotifierProvider);
    final todayDate = _localDay(todayState.selectedDate);

    final shouldRefreshSelectedMutationDay = _isSameLocalDay(todayDate, date);

    await ref
        .read(todayNotifierProvider.notifier)
        .load(date: shouldRefreshSelectedMutationDay ? date : todayDate);
  }

  Future<void> _refreshTimeline({required DateTime date}) async {
    final timelineState = ref.read(timelineNotifierProvider);
    final timelineDate = _localDay(timelineState.selectedDate);

    final shouldRefreshSelectedMutationDay = _isSameLocalDay(
      timelineDate,
      date,
    );

    await ref
        .read(timelineNotifierProvider.notifier)
        .loadDay(date: shouldRefreshSelectedMutationDay ? date : timelineDate);
  }

  DateTime _localDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameLocalDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
