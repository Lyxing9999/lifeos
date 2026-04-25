import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/content/product_terms.dart';
import '../../../../core/widgets/expandable_text_block.dart';
import '../../domain/model/daily_score.dart';

class ScoreBreakdownCard extends StatelessWidget {
  final DailyScore score;

  const ScoreBreakdownCard({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ProductTerms.whyThisScore,
              style: AppTextStyles.cardTitle(context),
            ),
            const SizedBox(height: 2),
            Text(
              'The signals that moved this score for the selected day',
              style: AppTextStyles.bodySecondary(context),
            ),
            const SizedBox(height: AppSpacing.md),
            _row(
              context,
              'Completed tasks',
              '${score.completedTasks}/${score.totalTasks}',
            ),
            _row(
              context,
              ProductTerms.plannedBlocks,
              '${score.totalPlannedBlocks}',
            ),
            _row(
              context,
              ProductTerms.staySessions,
              '${score.totalStaySessions}',
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'What to improve next',
              style: AppTextStyles.cardTitle(context),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(_insightSentence(), style: AppTextStyles.bodyPrimary(context)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _improvementSentence(),
              style: AppTextStyles.bodyPrimary(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            ExpandableTextBlock(
              text: _technicalDetails(),
              collapsedMaxLines: 2,
              expandLabel: 'Show technical detail',
              collapseLabel: 'Hide technical detail',
              style: AppTextStyles.bodySecondary(context),
            ),
            if ((score.scoreExplanation ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                score.scoreExplanation!,
                style: AppTextStyles.bodySecondary(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTextStyles.cardSubtitle(context)),
          ),
          Text(value, style: AppTextStyles.cardTitle(context)),
        ],
      ),
    );
  }

  String _insightSentence() {
    final completionRead = switch (score.completionScore) {
      >= 80 => 'Completion was strong',
      >= 50 => 'Completion was moderate',
      _ => 'Completion was light',
    };

    final structureRead = score.totalStaySessions == 0
        ? 'structure stayed lower because no stay sessions were recorded.'
        : 'structure stayed lower because day structure signals were limited.';

    return '$completionRead today; $structureRead';
  }

  String _improvementSentence() {
    return 'Keep more of the day tied to planned blocks, or generate stay sessions from location logs.';
  }

  String _technicalDetails() {
    return 'Completion score ${score.completionScore} '
        '(${score.completedTasks}/${score.totalTasks} tasks). '
        'Structure score ${score.structureScore} '
        '(${score.totalPlannedBlocks} planned blocks, ${score.totalStaySessions} stay sessions).';
  }
}
