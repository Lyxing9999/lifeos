import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/content/product_terms.dart';
import '../../../../core/widgets/app_stat_block.dart';
import '../../domain/model/timeline_day.dart';

class TimelineSummaryCard extends StatelessWidget {
  final TimelineDay day;

  const TimelineSummaryCard({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    final topPlaceName = _safeTopPlace(day.summary.topPlaceName);

    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ProductTerms.dayOverview,
              style: AppTextStyles.cardTitle(context),
            ),
            const SizedBox(height: 2),
            Text(
              ProductCopy.timelineSubtitle,
              style: AppTextStyles.bodySecondary(context),
            ),
            if (topPlaceName != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${ProductTerms.topPlace}: $topPlaceName',
                style: AppTextStyles.metaLabel(context),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppStatBlock(
                    label: 'Tasks',
                    value:
                        '${day.summary.completedTasks}/${day.summary.totalTasks}',
                    helper: 'Done',
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppStatBlock(
                    label: 'Blocks',
                    value: '${day.summary.totalPlannedBlocks}',
                    helper: 'Planned',
                    color: AppColors.blue,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppStatBlock(
                    label: 'Stays',
                    value: '${day.summary.totalStaySessions}',
                    helper: 'Detected',
                    color: AppColors.indigo,
                  ),
                ),
              ],
            ),
            if (day.financialSummary.totalFinancialEvents > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: 168,
                child: AppStatBlock(
                  label: 'Spending',
                  value: day.financialSummary.totalOutgoingAmount
                      .toStringAsFixed(0),
                  helper: 'Events',
                  color: AppColors.amber,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? _safeTopPlace(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    final lower = value.toLowerCase();
    if (lower == 'unknown' ||
        lower == 'unknown place' ||
        lower == 'unclassified') {
      return null;
    }

    return value;
  }
}
