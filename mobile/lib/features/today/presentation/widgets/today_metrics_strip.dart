import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_stat_block.dart';

class TodayMetricsStrip extends StatelessWidget {
  final int totalTasks;
  final int completedTasks;
  final int plannedBlocks;
  final VoidCallback? onTap;

  const TodayMetricsStrip({
    super.key,
    required this.totalTasks,
    required this.completedTasks,
    required this.plannedBlocks,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final completionLabel = totalTasks <= 0
        ? 'No tasks'
        : '$completedTasks of $totalTasks done';

    return AppCard(
      glass: true,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Day load',
                    style: AppTextStyles.cardTitle(context),
                  ),
                ),
                if (onTap != null)
                  Icon(
                    AppIcons.chevronRight,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(completionLabel, style: AppTextStyles.bodySecondary(context)),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppStatBlock(
                    label: 'Tasks',
                    value: '$totalTasks',
                    helper: 'Intent',
                    color: AppColors.blue,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppStatBlock(
                    label: 'Done',
                    value: '$completedTasks',
                    helper: 'Progress',
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppStatBlock(
                    label: 'Planned',
                    value: '$plannedBlocks',
                    helper: 'Blocks',
                    color: AppColors.violet,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
