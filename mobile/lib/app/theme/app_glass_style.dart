import 'package:flutter/material.dart';

import 'app_radius.dart';

abstract final class AppGlassStyle {
  static const double iconBlurSigma = 12;
  static const double headerBlurSigma = 18;
  static const double cardBlurSigma = 16;
  static const double toastBlurSigma = 18;
  static const double modalBlurSigma = 20;

  static BoxDecoration surfaceDecoration(
    BuildContext context, {
    required BorderRadius borderRadius,
    double lightSurfaceAlpha = 0.82,
    double darkSurfaceAlpha = 0.64,
    double lightBorderAlpha = 0.40,
    double darkBorderAlpha = 0.30,
    double lightShadowAlpha = 0.045,
    double darkShadowAlpha = 0.14,
    double shadowBlurRadius = 16,
    Offset shadowOffset = const Offset(0, 6),
    Color? accentColor,
    double lightAccentShadowAlpha = 0.07,
    double darkAccentShadowAlpha = 0.04,
    double accentShadowBlurRadius = 18,
    double accentShadowOffsetY = 4,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: scheme.surface.withValues(
        alpha: isDark ? darkSurfaceAlpha : lightSurfaceAlpha,
      ),
      borderRadius: borderRadius,
      border: Border.all(
        color: scheme.outlineVariant.withValues(
          alpha: isDark ? darkBorderAlpha : lightBorderAlpha,
        ),
        width: 0.8,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: isDark ? darkShadowAlpha : lightShadowAlpha,
          ),
          blurRadius: shadowBlurRadius,
          offset: shadowOffset,
        ),
        if (accentColor != null)
          BoxShadow(
            color: accentColor.withValues(
              alpha: isDark ? darkAccentShadowAlpha : lightAccentShadowAlpha,
            ),
            blurRadius: accentShadowBlurRadius,
            offset: Offset(0, accentShadowOffsetY),
          ),
      ],
    );
  }

  static BoxDecoration iconButtonDecoration(
    BuildContext context, {
    required bool selected,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: selected
          ? scheme.primaryContainer.withValues(alpha: isDark ? 0.32 : 0.46)
          : scheme.surfaceContainerHighest.withValues(
              alpha: isDark ? 0.38 : 0.62,
            ),
      borderRadius: BorderRadius.circular(AppRadius.full),
      border: Border.all(
        color: selected
            ? scheme.primary.withValues(alpha: 0.34)
            : scheme.outlineVariant.withValues(alpha: 0.34),
        width: 0.8,
      ),
    );
  }

  static BoxDecoration headerDecoration(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: scheme.surface.withValues(alpha: isDark ? 0.66 : 0.82),
      border: Border(
        bottom: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: isDark ? 0.28 : 0.38),
          width: 0.7,
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.035),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  static BoxDecoration cardDecoration(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: scheme.surface.withValues(alpha: isDark ? 0.60 : 0.80),
      borderRadius: BorderRadius.circular(AppRadius.card),
      border: Border.all(
        color: scheme.outlineVariant.withValues(alpha: isDark ? 0.30 : 0.40),
        width: 0.8,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.045),
          blurRadius: 18,
          offset: const Offset(0, 7),
        ),
      ],
    );
  }

  static BoxDecoration floatingDecoration(
    BuildContext context, {
    required BorderRadius borderRadius,
    Color? accentColor,
  }) {
    return surfaceDecoration(
      context,
      borderRadius: borderRadius,
      lightSurfaceAlpha: 0.90,
      darkSurfaceAlpha: 0.70,
      lightBorderAlpha: 0.30,
      darkBorderAlpha: 0.30,
      lightShadowAlpha: 0.11,
      darkShadowAlpha: 0.22,
      shadowBlurRadius: 24,
      shadowOffset: const Offset(0, 10),
      accentColor: accentColor,
      lightAccentShadowAlpha: 0.055,
      darkAccentShadowAlpha: 0.065,
      accentShadowBlurRadius: 18,
      accentShadowOffsetY: 5,
    );
  }

  static BoxDecoration modalDecoration(
    BuildContext context, {
    required BorderRadius borderRadius,
    Color? accentColor,
  }) {
    return surfaceDecoration(
      context,
      borderRadius: borderRadius,
      lightSurfaceAlpha: 0.88,
      darkSurfaceAlpha: 0.68,
      lightBorderAlpha: 0.34,
      darkBorderAlpha: 0.30,
      lightShadowAlpha: 0.13,
      darkShadowAlpha: 0.26,
      shadowBlurRadius: 34,
      shadowOffset: const Offset(0, 16),
      accentColor: accentColor,
      lightAccentShadowAlpha: 0.055,
      darkAccentShadowAlpha: 0.06,
      accentShadowBlurRadius: 22,
      accentShadowOffsetY: 8,
    );
  }
}
