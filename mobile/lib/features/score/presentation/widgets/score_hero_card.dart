import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_stat_block.dart';
import '../../domain/model/daily_score.dart';

class ScoreHeroCard extends StatelessWidget {
  final DailyScore score;

  const ScoreHeroCard({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.scoreColor(score.overallScore);

    return AppCard(
      glass: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${score.overallScore}',
            style: AppTextStyles.scoreHero(context).copyWith(color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Daily score', style: AppTextStyles.statLabel(context)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Higher scores mean the day stayed more complete and more structured.',
            style: AppTextStyles.bodySecondary(context),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppStatBlock(
                  label: 'Completion',
                  value: '${score.completionScore}',
                  helper: 'Score',
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppStatBlock(
                  label: 'Structure',
                  value: '${score.structureScore}',
                  helper: 'Score',
                  color: AppColors.violet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
