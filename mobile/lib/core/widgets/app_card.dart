import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';

/// LifeOS shared card system.
/// Three variants enforcing the card contract across all features.
/// No widget should define its own Card shape/border/elevation inline.

/// Standard content card — padded, non-interactive.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: padding ?? AppSpacing.cardInsets,
        child: child,
      ),
    );
  }
}

/// Interactive card — tappable with InkWell ripple.
/// Use for list items, quick actions, and navigable cards.
class AppCardInteractive extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const AppCardInteractive({
    super.key,
    required this.child,
    required this.onTap,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding ?? AppSpacing.cardInsets,
          child: child,
        ),
      ),
    );
  }
}

/// Compact stat card — centered content, smaller padding.
/// Use for score tiles, stat boxes, and metric displays.
class AppCardStat extends StatelessWidget {
  final Widget child;
  final Color? color;

  const AppCardStat({
    super.key,
    required this.child,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: AppSpacing.cardInsetsSm,
        child: child,
      ),
    );
  }
}
