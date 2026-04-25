import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class AppStatusBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final List<Widget>? actions;

  const AppStatusBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: AppColors.cellBg(context, color),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: color.withValues(alpha: 0.18), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppSpacing.iconContainerSize,
                height: AppSpacing.iconContainerSize,
                decoration: BoxDecoration(
                  color: AppColors.iconBg(context, color),
                  borderRadius: BorderRadius.circular(AppRadius.icon),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.cardTitle(
                        context,
                      ).copyWith(color: color),
                    ),
                    const SizedBox(height: 2),
                    Text(message, style: AppTextStyles.bodySecondary(context)),
                  ],
                ),
              ),
            ],
          ),
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: actions!,
            ),
          ],
        ],
      ),
    );
  }
}
