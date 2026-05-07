import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifeos_mobile/features/schedule/domain/enum/schedule_block_type.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../domain/enum/schedule_recurrence_type.dart';
import '../../domain/entities/schedule_occurrence.dart';
import 'schedule_type_visuals.dart';

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
    final now = DateTime.now();

    // Time Awareness Logic
    final isPast = now.isAfter(item.endDateTime);
    final isCurrent =
        now.isAfter(item.startDateTime) && now.isBefore(item.endDateTime);

    final baseColor = ScheduleTypeVisuals.colorOf(item.type);

    // Mute the color if the time has passed
    final color = isPast ? Theme.of(context).colorScheme.outline : baseColor;

    return AppCardInteractive(
      onTap: onTap,
      padding: EdgeInsets.zero,
      color: isCurrent
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : null,
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
                        ScheduleTypeVisuals.iconOf(item.type),
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
                            style: AppTextStyles.cardTitle(context).copyWith(
                              color: isPast
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant
                                  : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.type.label} · ${_timeRange(item)}',
                            style: AppTextStyles.cardSubtitle(context),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Wrap(
                            spacing: AppSpacing.xs,
                            children: [
                              if (isCurrent)
                                AppChip.status(
                                  label: 'Happening now',
                                  color: baseColor,
                                )
                              else if (isPast)
                                AppChip.status(
                                  label: 'Passed',
                                  color: Theme.of(context).colorScheme.outline,
                                )
                              else
                                AppChip.status(label: 'Planned', color: color),

                              if (item.recurrenceType !=
                                  ScheduleRecurrenceType.none)
                                AppChip.metadata(
                                  label: 'Repeats',
                                  icon: AppIcons.recurrence,
                                )
                              else
                                AppChip.metadata(
                                  label: 'One-time',
                                  icon: AppIcons.date,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(
                      AppIcons.chevronRight,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeRange(ScheduleOccurrence item) {
    final format = DateFormat('h:mm a');
    return '${format.format(item.startDateTime)} - ${format.format(item.endDateTime)}';
  }
}
