import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/content/product_terms.dart';
import '../../../../core/widgets/app_stat_block.dart';
import '../../../../core/widgets/expandable_text_block.dart';

class AiSummaryCard extends StatelessWidget {
  final String summaryText;
  final String topPlaceName;
  final int totalTasks;
  final int completedTasks;
  final int totalPlannedBlocks;
  final int totalStaySessions;
  final int summaryMaxLines;
  final bool allowExpand;

  const AiSummaryCard({
    super.key,
    required this.summaryText,
    required this.topPlaceName,
    required this.totalTasks,
    required this.completedTasks,
    required this.totalPlannedBlocks,
    required this.totalStaySessions,
    this.summaryMaxLines = 5,
    this.allowExpand = true,
  });

  @override
  Widget build(BuildContext context) {
    final safePlace = _sanitizePlaceName(topPlaceName);
    final topPlaceLine = safePlace.isEmpty ? 'No dominant place' : safePlace;

    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: AppSpacing.iconContainerSize,
                  height: AppSpacing.iconContainerSize,
                  decoration: BoxDecoration(
                    color: AppColors.iconBg(context, AppColors.violet),
                    borderRadius: BorderRadius.circular(AppRadius.icon),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.violet,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily reflection',
                        style: AppTextStyles.cardTitle(context),
                      ),
                      Text(
                        'A readable wrap-up of this day',
                        style: AppTextStyles.aiLabel(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ExpandableTextBlock(
              text: summaryText.isEmpty
                  ? 'No summary available yet.'
                  : summaryText,
              collapsedMaxLines: summaryMaxLines,
              allowExpand: allowExpand,
              style: AppTextStyles.bodyPrimary(context).copyWith(height: 1.65),
            ),
            if (safePlace.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
            ] else
              const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.place_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '${ProductTerms.topPlace}: $topPlaceLine',
                    style: AppTextStyles.bodySecondary(
                      context,
                    ).copyWith(height: 1.55),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppStatBlock(
                    label: 'Tasks',
                    value: '$completedTasks/$totalTasks',
                    helper: 'Done',
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppStatBlock(
                    label: 'Blocks',
                    value: '$totalPlannedBlocks',
                    helper: 'Planned',
                    color: AppColors.violet,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppStatBlock(
                    label: 'Stays',
                    value: '$totalStaySessions',
                    helper: 'Detected',
                    color: AppColors.indigo,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _sanitizePlaceName(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower.isEmpty ||
        lower == 'unknown' ||
        lower == 'unknown place' ||
        lower == 'unclassified') {
      return '';
    }
    return raw.trim();
  }
}
