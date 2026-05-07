import 'schedule_block.dart';
import 'schedule_count_summary.dart';
import '../enum/schedule_filter.dart';
import '../enum/schedule_view_filter.dart';

class ScheduleSurfaceOverview {
  final DateTime date;
  final List<ScheduleBlock> activeBlocks;
  final List<ScheduleBlock> inactiveBlocks;
  final List<ScheduleBlock> historyBlocks; // NEW: Direct from Backend!
  final ScheduleCountSummary counts;

  const ScheduleSurfaceOverview({
    required this.date,
    required this.activeBlocks,
    required this.inactiveBlocks,
    required this.historyBlocks,
    required this.counts,
  });

  /// Logic mirrors the Task module for consistency
  List<ScheduleBlock> blocksFor(
    ScheduleFilter statusFilter,
    ScheduleViewFilter viewFilter,
  ) {
    // 1. Determine status bucket
    // (Backend already guaranteed inactiveBlocks has NO expired items!)
    final baseList = statusFilter == ScheduleFilter.active
        ? activeBlocks
        : inactiveBlocks;

    // 2. Apply Category filter locally (Work, Study, etc.)
    if (viewFilter == ScheduleViewFilter.all) return baseList;

    return baseList
        .where(
          (block) =>
              block.type.name.toLowerCase() == viewFilter.name.toLowerCase(),
        )
        .toList();
  }
}
