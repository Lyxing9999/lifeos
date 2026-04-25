import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class ScoreExplanationCard extends StatelessWidget {
  final String text;

  const ScoreExplanationCard({super.key, required this.text});

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
                    color: AppColors.iconBg(context, AppColors.violet),
                    borderRadius: BorderRadius.circular(
                      AppSpacing.iconContainerRadius,
                    ),
                  ),
                  child: const Icon(
                    Icons.psychology_alt_outlined,
                    color: AppColors.violet,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Why this score?',
                    style: AppTextStyles.cardTitle(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(text, style: AppTextStyles.bodyPrimary(context)),
          ],
        ),
      ),
    );
  }
}
