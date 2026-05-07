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
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: AppColors.cellBg(context, color),
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
        border: Border.all(color: color.withValues(alpha: 0.18), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.12
                  : 0.035,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BannerIcon(icon: icon, color: color),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.cardTitle(
                        context,
                      ).copyWith(color: color, letterSpacing: -0.12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      message,
                      style: AppTextStyles.bodySecondary(
                        context,
                      ).copyWith(color: scheme.onSurfaceVariant, height: 1.32),
                    ),
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

class _BannerIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _BannerIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.iconContainerSize,
      height: AppSpacing.iconContainerSize,
      decoration: BoxDecoration(
        color: AppColors.iconBg(context, color),
        borderRadius: BorderRadius.circular(AppRadius.icon),
        border: Border.all(color: color.withValues(alpha: 0.14), width: 0.7),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}
