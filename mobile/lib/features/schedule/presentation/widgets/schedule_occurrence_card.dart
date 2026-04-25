import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../domain/enum/schedule_block_type.dart';
import '../../domain/model/schedule_occurrence.dart';

class ScheduleOccurrenceCard extends StatelessWidget {
  final ScheduleOccurrence item;
  final VoidCallback onTap;

  const ScheduleOccurrenceCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(item.type);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: color),
              Expanded(
                child: Padding(
                  padding: AppSpacing.cardInsets,
                  child: Row(
                    children: [
                      Container(
                        width: AppSpacing.iconContainerSize,
                        height: AppSpacing.iconContainerSize,
                        decoration: BoxDecoration(
                          color: AppColors.iconBg(context, color),
                          borderRadius: BorderRadius.circular(AppRadius.icon),
                        ),
                        child: Icon(
                          _typeIcon(item.type),
                          color: color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: AppTextStyles.cardTitle(context),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.type.label} · ${_timeRange(item)}',
                              style: AppTextStyles.cardSubtitle(context),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            AppChip.status(
                              label: 'Planned block',
                              color: color,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _typeColor(ScheduleBlockType type) {
    switch (type) {
      case ScheduleBlockType.work:
        return AppColors.blue;
      case ScheduleBlockType.study:
        return AppColors.violet;
      case ScheduleBlockType.meeting:
        return AppColors.indigo;
      case ScheduleBlockType.exercise:
        return AppColors.green;
      case ScheduleBlockType.rest:
        return AppColors.teal;
      case ScheduleBlockType.commute:
        return AppColors.amber;
      case ScheduleBlockType.personal:
        return AppColors.sky;
      case ScheduleBlockType.other:
        return AppColors.slate;
    }
  }

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
}

String _timeRange(ScheduleOccurrence item) {
  final format = DateFormat('h:mm a');
  return '${format.format(item.startDateTime)} - ${format.format(item.endDateTime)}';
}
