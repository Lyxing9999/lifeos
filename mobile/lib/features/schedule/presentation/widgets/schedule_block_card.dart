import 'package:flutter/material.dart';
import 'package:lifeos_mobile/features/schedule/domain/enum/schedule_block_type.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../domain/enum/schedule_recurrence_type.dart';
import '../../domain/entities/schedule_block.dart';
import 'schedule_type_visuals.dart';

class ScheduleBlockCard extends StatelessWidget {
  final ScheduleBlock block;
  final VoidCallback onTap;

  const ScheduleBlockCard({
    super.key,
    required this.block,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = ScheduleTypeVisuals.colorOf(block.type);

    // Mute the card if the blueprint rule is currently deactivated
    final isMuted = !block.active;
    final displayColor = isMuted
        ? Theme.of(context).colorScheme.outline
        : color;

    return AppCardInteractive(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: displayColor),
            Expanded(
              child: Padding(
                padding: AppSpacing.cardInsets,
                child: Row(
                  children: [
                    Container(
                      width: AppSpacing.iconContainerSize,
                      height: AppSpacing.iconContainerSize,
                      decoration: BoxDecoration(
                        color: AppColors.iconBg(context, displayColor),
                        borderRadius: BorderRadius.circular(AppRadius.icon),
                      ),
                      child: Icon(
                        ScheduleTypeVisuals.iconOf(block.type),
                        color: displayColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            block.title,
                            style: AppTextStyles.cardTitle(context).copyWith(
                              color: isMuted
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
                            '${block.type.label} · ${block.startTime.format(context)} - ${block.endTime.format(context)}',
                            style: AppTextStyles.cardSubtitle(context),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Wrap(
                            spacing: AppSpacing.xs,
                            children: [
                              AppChip.metadata(
                                label: block.recurrenceType.label,
                                icon:
                                    block.recurrenceType ==
                                        ScheduleRecurrenceType.none
                                    ? AppIcons.date
                                    : AppIcons.recurrence,
                              ),
                              if (isMuted)
                                AppChip.status(
                                  label: 'Inactive',
                                  color: Theme.of(context).colorScheme.outline,
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
}
