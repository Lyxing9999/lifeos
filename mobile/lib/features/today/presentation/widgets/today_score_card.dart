import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_stat_block.dart';

class TodayScoreCard extends StatelessWidget {
  final int overallScore;
  final int completionScore;
  final int structureScore;
  final VoidCallback? onTap;

  const TodayScoreCard({
    super.key,
    required this.overallScore,
    required this.completionScore,
    required this.structureScore,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final overallColor = AppColors.scoreColor(overallScore);
    final cs = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.cardInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily score',
                          style: AppTextStyles.cardTitle(context),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Completion and structure',
                          style: AppTextStyles.bodySecondary(context),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    constraints: const BoxConstraints(minWidth: 64),
                    decoration: BoxDecoration(
                      color: AppColors.scoreSubtle(context, overallScore),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      '$overallScore',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.scoreHero(context).copyWith(
                        color: overallColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppStatBlock(
                      label: 'Completion',
                      value: '$completionScore',
                      helper: 'Score',
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppStatBlock(
                      label: 'Structure',
                      value: '$structureScore',
                      helper: 'Score',
                      color: AppColors.violet,
                    ),
                  ),
                ],
              ),
              if (onTap != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      'See breakdown',
                      style: AppTextStyles.metaLabel(
                        context,
                      ).copyWith(color: cs.primary),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: cs.primary,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
