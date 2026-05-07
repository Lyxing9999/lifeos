import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/model/today_financial_insight.dart';

class TodayFinancialInsightCard extends StatelessWidget {
  final TodayFinancialInsight insight;
  final VoidCallback? onTap;

  const TodayFinancialInsightCard({
    super.key,
    required this.insight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = insight.totalEvents > 0;

    return AppCard(
      glass: true,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.iconBg(context, AppColors.amber),
                    borderRadius: BorderRadius.circular(AppRadius.icon),
                  ),
                  child: const Icon(
                    AppIcons.spending,
                    color: AppColors.amber,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Spending',
                    style: AppTextStyles.sectionHeader(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              hasData
                  ? '${insight.totalOutgoingAmount.toStringAsFixed(2)}'
                        '${insight.latestCurrency.isEmpty ? '' : ' ${insight.latestCurrency}'}'
                  : '0.00',
              style: AppTextStyles.cardTitle(
                context,
              ).copyWith(color: AppColors.amber),
            ),
            const SizedBox(height: 2),
            Text(
              hasData
                  ? '${insight.totalEvents} event${insight.totalEvents == 1 ? '' : 's'} today'
                  : 'No spending reported',
              style: AppTextStyles.bodySecondary(context),
            ),
            if (onTap != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Open spending',
                style: AppTextStyles.metaLabel(
                  context,
                ).copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
