import 'package:flutter/material.dart';

/// LifeOS named text style accessors.
/// Use these instead of inline theme.textTheme.xxx?.copyWith(...) calls.
abstract final class AppTextStyles {
  static TextStyle pageTitle(BuildContext context) => Theme.of(context)
      .textTheme
      .headlineMedium!
      .copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.6);

  static TextStyle sectionHeader(BuildContext context) =>
      Theme.of(context).textTheme.titleSmall!.copyWith(
        fontWeight: FontWeight.w700,
        color: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.88),
        letterSpacing: 0.1,
      );

  static TextStyle cardTitle(BuildContext context) => Theme.of(
    context,
  ).textTheme.titleMedium!.copyWith(
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
  );

  static TextStyle cardSubtitle(BuildContext context) => Theme.of(context)
      .textTheme
      .bodySmall!
      .copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        height: 1.4,
      );

  static TextStyle bodyPrimary(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.55);

  static TextStyle bodySecondary(BuildContext context) => Theme.of(context)
      .textTheme
      .bodyMedium!
      .copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        height: 1.45,
      );

  static TextStyle statValue(BuildContext context) => Theme.of(
    context,
  ).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w700);

  static TextStyle scoreHero(BuildContext context) => Theme.of(context)
      .textTheme
      .displaySmall!
      .copyWith(fontWeight: FontWeight.w800, letterSpacing: -1);

  static TextStyle statLabel(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall!.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      );

  static TextStyle metaLabel(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall!.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.25,
      );

  static TextStyle chipLabel(BuildContext context) => Theme.of(
    context,
  ).textTheme.labelSmall!.copyWith(fontWeight: FontWeight.w700);

  static TextStyle aiLabel(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall!.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 0.35,
        fontWeight: FontWeight.w600,
      );

  static TextStyle timeLabel(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge!.copyWith(
        fontWeight: FontWeight.w600,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle timeLabelSm(BuildContext context) =>
      Theme.of(context).textTheme.labelMedium!.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle dayLabel(BuildContext context) => Theme.of(
    context,
  ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700);

  static TextStyle dayCount(BuildContext context) => Theme.of(context)
      .textTheme
      .bodySmall!
      .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
}
