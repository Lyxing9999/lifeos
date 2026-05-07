import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_button.dart';

class AppSparseStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? color;

  const AppSparseStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SparseIcon(icon: icon, color: accent),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.cardTitle(
                      context,
                    ).copyWith(color: scheme.onSurface, letterSpacing: -0.12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    message,
                    style: AppTextStyles.bodySecondary(
                      context,
                    ).copyWith(height: 1.32),
                  ),
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppButton.secondary(
                        label: actionLabel!,
                        icon: AppIcons.chevronRight,
                        onPressed: onAction,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparseIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SparseIcon({required this.icon, required this.color});

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
