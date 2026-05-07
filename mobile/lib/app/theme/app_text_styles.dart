import 'package:flutter/material.dart';

/// LifeOS named text style accessors.
///
/// Use these instead of repeated inline:
/// Theme.of(context).textTheme.xxx?.copyWith(...)
abstract final class AppTextStyles {
  static TextStyle pageTitle(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Theme.of(context).textTheme.headlineMedium!.copyWith(
      color: scheme.onSurface,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.6,
      height: 1.08,
    );
  }

  static TextStyle sectionHeader(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Theme.of(context).textTheme.titleSmall!.copyWith(
      color: scheme.onSurface.withValues(alpha: 0.90),
      fontWeight: FontWeight.w800,
      letterSpacing: -0.05,
      height: 1.18,
    );
  }

  static TextStyle cardTitle(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Theme.of(context).textTheme.titleMedium!.copyWith(
      color: scheme.onSurface,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.15,
      height: 1.20,
    );
  }

  static TextStyle cardSubtitle(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Theme.of(context).textTheme.bodySmall!.copyWith(
      color: scheme.onSurfaceVariant,
      height: 1.40,
    );
  }

  static TextStyle bodyPrimary(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Theme.of(
      context,
    ).textTheme.bodyLarge!.copyWith(color: scheme.onSurface, height: 1.52);
  }

  static TextStyle bodySecondary(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: scheme.onSurfaceVariant,
      height: 1.42,
    );
  }

  static TextStyle statValue(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Theme.of(context).textTheme.headlineSmall!.copyWith(
      color: scheme.onSurface,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.35,
      height: 1.05,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle scoreHero(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Theme.of(context).textTheme.displaySmall!.copyWith(
      color: scheme.onSurface,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.0,
      height: 1.0,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle statLabel(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Theme.of(context).textTheme.labelSmall!.copyWith(
      color: scheme.onSurfaceVariant,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.28,
      height: 1.16,
    );
  }

  static TextStyle metaLabel(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Theme.of(context).textTheme.labelSmall!.copyWith(
      color: scheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.22,
      height: 1.16,
    );
  }

  static TextStyle chipLabel(BuildContext context) {
    return Theme.of(context).textTheme.labelSmall!.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.02,
      height: 1.15,
    );
  }

  static TextStyle aiLabel(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Theme.of(context).textTheme.labelSmall!.copyWith(
      color: scheme.onSurfaceVariant,
      letterSpacing: 0.35,
      fontWeight: FontWeight.w700,
      height: 1.16,
    );
  }

  static TextStyle timeLabel(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Theme.of(context).textTheme.labelLarge!.copyWith(
      color: scheme.onSurface,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.08,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle timeLabelSm(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Theme.of(context).textTheme.labelMedium!.copyWith(
      color: scheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle dayLabel(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Theme.of(context).textTheme.titleMedium!.copyWith(
      color: scheme.onSurface,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.25,
    );
  }

  static TextStyle dayCount(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Theme.of(context).textTheme.bodySmall!.copyWith(
      color: scheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
      height: 1.25,
    );
  }
}
