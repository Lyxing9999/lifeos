import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';
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

    final chip = AnimatedContainer(
      duration: AppMotion.duration(context, AppMotion.fast),
      curve: AppMotion.standardCurve,
      padding: config.padding,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(config.radius),
        border: Border.all(
          color: config.borderColor,
          width: config.borderWidth,
        ),
        boxShadow: config.shadows,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: config.iconSize, color: config.foregroundColor),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.chipLabel(context).copyWith(
                color: config.foregroundColor,
                fontWeight: config.fontWeight,
                letterSpacing: -0.05,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return chip;
    }

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(config.radius),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap?.call();
          },
          borderRadius: BorderRadius.circular(config.radius),
          splashColor: config.foregroundColor.withValues(alpha: 0.08),
          highlightColor: config.foregroundColor.withValues(alpha: 0.04),
          child: chip,
        ),
      ),
    );
  }

  _AppChipStyle _resolveStyle(BuildContext context, Color accent) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (role) {
      case AppChipRole.filter:
        if (selected) {
          return _AppChipStyle(
            backgroundColor: AppColors.chipBg(context, accent),
            borderColor: accent.withValues(alpha: isDark ? 0.34 : 0.28),
            foregroundColor: accent,
            borderWidth: 1,
            radius: AppRadius.full,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            iconSize: 13.5,
            fontWeight: FontWeight.w800,
            shadows: [
              BoxShadow(
                color: accent.withValues(alpha: isDark ? 0.08 : 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          );
        }

        return _AppChipStyle(
          backgroundColor: scheme.surfaceContainerHighest.withValues(
            alpha: isDark ? 0.46 : 0.72,
          ),
          borderColor: scheme.outlineVariant.withValues(alpha: 0.46),
          foregroundColor: scheme.onSurfaceVariant,
          borderWidth: 0.8,
          radius: AppRadius.full,
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          iconSize: 13.5,
          fontWeight: FontWeight.w600,
          shadows: const [],
        );

      case AppChipRole.status:
        return _AppChipStyle(
          backgroundColor: AppColors.chipBg(context, accent),
          borderColor: accent.withValues(alpha: isDark ? 0.26 : 0.18),
          foregroundColor: accent,
          borderWidth: 0.8,
          radius: AppRadius.full,
          padding: AppSpacing.chipInsets,
          iconSize: 13,
          fontWeight: FontWeight.w700,
          shadows: const [],
        );

      case AppChipRole.metadata:
        return _AppChipStyle(
          backgroundColor: scheme.surfaceContainerHighest.withValues(
            alpha: isDark ? 0.34 : 0.56,
          ),
          borderColor: scheme.outlineVariant.withValues(alpha: 0.42),
          foregroundColor: color ?? scheme.onSurfaceVariant,
          borderWidth: 0.8,
          radius: AppRadius.full,
          padding: AppSpacing.chipInsets,
          iconSize: 13,
          fontWeight: FontWeight.w600,
          shadows: const [],
        );

      case AppChipRole.stat:
        return _AppChipStyle(
          backgroundColor: AppColors.cellBg(context, accent),
          borderColor: accent.withValues(alpha: isDark ? 0.22 : 0.14),
          foregroundColor: accent,
          borderWidth: 0.8,
          radius: AppRadius.card,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          iconSize: 14,
          fontWeight: FontWeight.w800,
          shadows: [
            BoxShadow(
              color: accent.withValues(alpha: isDark ? 0.05 : 0.035),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
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
  final double iconSize;
  final FontWeight fontWeight;
  final List<BoxShadow> shadows;

  const _AppChipStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.foregroundColor,
    required this.borderWidth,
    required this.radius,
    required this.padding,
    required this.iconSize,
    required this.fontWeight,
    required this.shadows,
  });
}
