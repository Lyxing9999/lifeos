import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';

class TodayScoreInsightCard extends StatelessWidget {
  final int overallScore;
  final int completionScore;
  final int structureScore;
  final int completedTasks;
  final int totalTasks;
  final int plannedBlocks;
  final String? explanation;
  final VoidCallback? onTap;

  const TodayScoreInsightCard({
    super.key,
    required this.overallScore,
    required this.completionScore,
    required this.structureScore,
    required this.completedTasks,
    required this.totalTasks,
    required this.plannedBlocks,
    this.explanation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final overallColor = AppColors.scoreColor(overallScore);
    final cs = Theme.of(context).colorScheme;

    return AppCard(
      glass: true,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _Header(supportText: _supportText())),
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
                    style: AppTextStyles.scoreHero(
                      context,
                    ).copyWith(color: overallColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _explanationText(),
              style: AppTextStyles.bodySecondary(context),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                AppChip.stat(
                  label: 'Completion $completionScore',
                  color: AppColors.green,
                ),
                AppChip.stat(
                  label: 'Structure $structureScore',
                  color: AppColors.violet,
                ),
              ],
            ),
            if (onTap != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Text(
                    'See why',
                    style: AppTextStyles.metaLabel(
                      context,
                    ).copyWith(color: cs.primary),
                  ),
                  const SizedBox(width: 4),
                  Icon(AppIcons.arrowRight, size: 14, color: cs.primary),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _supportText() {
    if (totalTasks <= 0 && plannedBlocks <= 0) {
      return 'No task or planned block signals yet.';
    }

    return '$completedTasks of $totalTasks tasks completed · $plannedBlocks planned blocks.';
  }

  String _explanationText() {
    final text = explanation?.trim();

    if (text != null && text.isNotEmpty) {
      return text;
    }

    if (overallScore >= 80) {
      return 'Strong completion and structure today.';
    }

    if (overallScore >= 50) {
      return 'A useful day is forming. Keep the next task clear.';
    }

    return 'Start with one clear task or planned block to give the day more structure.';
  }
}

class _Header extends StatelessWidget {
  final String supportText;

  const _Header({required this.supportText});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Day signal', style: AppTextStyles.cardTitle(context)),
        const SizedBox(height: AppSpacing.xs),
        Text(supportText, style: AppTextStyles.bodySecondary(context)),
      ],
    );
  }
}
