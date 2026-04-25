import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../summary/domain/model/daily_summary.dart';

class TodaySummaryCard extends StatelessWidget {
  final DailySummary summary;
  final VoidCallback? onTap;

  const TodaySummaryCard({super.key, required this.summary, this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = summary.summaryText.trim();
    final preview = text.isEmpty ? 'No reflection yet for this day.' : text;

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
                      size: 18,
                      color: AppColors.violet,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reflection',
                          style: AppTextStyles.cardTitle(context),
                        ),
                        Text(
                          'A calm read on how the day is going',
                          style: AppTextStyles.bodySecondary(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                preview,
                style: AppTextStyles.bodyPrimary(context).copyWith(height: 1.6),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              if (onTap != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Open full reflection',
                  style: AppTextStyles.metaLabel(
                    context,
                  ).copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
