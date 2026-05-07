import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';

class ScoreExplanationCard extends StatelessWidget {
  final String text;

  const ScoreExplanationCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    return AppCard(
      glass: true,
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
                  AppIcons.explanation,
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
    );
  }
}
