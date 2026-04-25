import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

enum AppChipRole { filter, status, metadata, stat }

class AppChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final AppChipRole role;
  final bool selected;
  final VoidCallback? onTap;

  const AppChip({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.role = AppChipRole.metadata,
    this.selected = false,
    this.onTap,
  });

  const AppChip.filter({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.selected = false,
    this.onTap,
  }) : role = AppChipRole.filter;

  const AppChip.status({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.onTap,
  }) : role = AppChipRole.status,
       selected = false;

  const AppChip.metadata({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.onTap,
  }) : role = AppChipRole.metadata,
       selected = false;

  const AppChip.stat({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.onTap,
  }) : role = AppChipRole.stat,
       selected = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = color ?? scheme.primary;
    final config = _resolveStyle(context, accent);

    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      padding: config.padding,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(config.radius),
        border: Border.all(
          color: config.borderColor,
          width: config.borderWidth,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: config.foregroundColor),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.chipLabel(
                context,
              ).copyWith(color: config.foregroundColor),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return child;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(config.radius),
      child: child,
    );
  }

  _AppChipStyle _resolveStyle(BuildContext context, Color accent) {
    final scheme = Theme.of(context).colorScheme;

    switch (role) {
      case AppChipRole.filter:
        if (selected) {
          return _AppChipStyle(
            backgroundColor: AppColors.chipBg(context, accent),
            borderColor: accent.withValues(alpha: 0.28),
            foregroundColor: accent,
            borderWidth: 1.2,
            radius: AppRadius.full,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          );
        }

        return _AppChipStyle(
          backgroundColor: scheme.surfaceContainerHighest,
          borderColor: scheme.outlineVariant,
          foregroundColor: scheme.onSurfaceVariant,
          borderWidth: 0.8,
          radius: AppRadius.full,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        );
      case AppChipRole.status:
        return _AppChipStyle(
          backgroundColor: AppColors.chipBg(context, accent),
          borderColor: accent.withValues(alpha: 0.18),
          foregroundColor: accent,
          borderWidth: 0.8,
          radius: AppRadius.full,
          padding: AppSpacing.chipInsets,
        );
      case AppChipRole.stat:
        return _AppChipStyle(
          backgroundColor: AppColors.cellBg(context, accent),
          borderColor: accent.withValues(alpha: 0.14),
          foregroundColor: accent,
          borderWidth: 0.8,
          radius: AppRadius.card,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        );
      case AppChipRole.metadata:
        return _AppChipStyle(
          backgroundColor: scheme.surfaceContainer,
          borderColor: scheme.outlineVariant,
          foregroundColor: color ?? scheme.onSurfaceVariant,
          borderWidth: 0.8,
          radius: AppRadius.full,
          padding: AppSpacing.chipInsets,
        );
    }
  }
}

class _AppChipStyle {
  final Color backgroundColor;
  final Color borderColor;
  final Color foregroundColor;
  final double borderWidth;
  final double radius;
  final EdgeInsets padding;

  const _AppChipStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.foregroundColor,
    required this.borderWidth,
    required this.radius,
    required this.padding,
  });
}
