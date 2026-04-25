import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/providers/clock_provider.dart';
import '../../../../core/utils/time_window_status.dart';
import '../../domain/model/today_current_schedule.dart';
import '../../../schedule/domain/enum/schedule_block_type.dart';

class TodayCurrentBlockCard extends ConsumerWidget {
  final TodayCurrentSchedule block;
  final VoidCallback? onTap;

  const TodayCurrentBlockCard({super.key, required this.block, this.onTap});

  IconData _typeIcon(ScheduleBlockType type) {
    switch (type) {
      case ScheduleBlockType.work:
        return Icons.work_outline;
      case ScheduleBlockType.study:
        return Icons.menu_book_outlined;
      case ScheduleBlockType.meeting:
        return Icons.groups_outlined;
      case ScheduleBlockType.exercise:
        return Icons.fitness_center_outlined;
      case ScheduleBlockType.rest:
        return Icons.bedtime_outlined;
      case ScheduleBlockType.commute:
        return Icons.directions_car_outlined;
      case ScheduleBlockType.personal:
        return Icons.person_outline;
      case ScheduleBlockType.other:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref
        .watch(clockProvider)
        .maybeWhen(data: (value) => value, orElse: DateTime.now);
    final status = timeWindowStatus(
      start: block.startDateTime,
      end: block.endDateTime,
      now: now,
    );
    final statusColor = switch (status) {
      TimeWindowStatus.now => AppColors.violet,
      TimeWindowStatus.upcoming => AppColors.violet,
      TimeWindowStatus.ended => AppColors.slate,
    };
    final statusLabel = switch (status) {
      TimeWindowStatus.now => 'NOW',
      TimeWindowStatus.upcoming => 'NEXT',
      TimeWindowStatus.ended => 'ENDED',
    };
    final eyebrow = switch (status) {
      TimeWindowStatus.now => 'Current moment',
      TimeWindowStatus.upcoming => 'Next block',
      TimeWindowStatus.ended => 'Ended',
    };
    final timeFormat = DateFormat('h:mm a');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.cardInsets,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.iconBg(context, statusColor),
                  borderRadius: BorderRadius.circular(AppRadius.icon),
                ),
                child: Icon(
                  _typeIcon(block.type),
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(eyebrow, style: AppTextStyles.metaLabel(context)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      block.title,
                      style: AppTextStyles.cardTitle(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${timeFormat.format(block.startDateTime)} - '
                      '${timeFormat.format(block.endDateTime)} · ${block.type.label}',
                      style: AppTextStyles.bodySecondary(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.chipBg(context, statusColor),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.16),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  statusLabel,
                  style: AppTextStyles.chipLabel(
                    context,
                  ).copyWith(color: statusColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
