import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/content/product_terms.dart';
import '../../../../core/widgets/expandable_text_block.dart';

class SummaryInsightCard extends StatelessWidget {
  final String text;

  const SummaryInsightCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

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
                    color: AppColors.iconBg(context, AppColors.amber),
                    borderRadius: BorderRadius.circular(AppRadius.icon),
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppColors.amber,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ProductTerms.worthNoticing,
                        style: AppTextStyles.cardTitle(context),
                      ),
                      Text(
                        'One useful signal from this day',
                        style: AppTextStyles.aiLabel(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ExpandableTextBlock(
              text: text,
              collapsedMaxLines: 4,
              style: AppTextStyles.bodyPrimary(context).copyWith(height: 1.65),
            ),
          ],
        ),
      ),
    );
  }
}
