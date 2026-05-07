import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_glass_style.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final bool glass;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.glass = false,
  });

  @override
  Widget build(BuildContext context) {
    return _AppCardShell(
      padding: padding ?? AppSpacing.cardInsets,
      color: color,
      glass: glass,
      child: child,
    );
  }
}

class AppCardInteractive extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final bool glass;

  const AppCardInteractive({
    super.key,
    required this.child,
    required this.onTap,
    this.padding,
    this.color,
    this.glass = false,
  });

  @override
  Widget build(BuildContext context) {
    return _AppCardShell(
      padding: padding ?? AppSpacing.cardInsets,
      color: color,
      glass: glass,
      onTap: onTap,
      child: child,
    );
  }
}

class AppCardStat extends StatelessWidget {
  final Widget child;
  final Color? color;
  final bool glass;

  const AppCardStat({
    super.key,
    required this.child,
    this.color,
    this.glass = false,
  });

  @override
  Widget build(BuildContext context) {
    return _AppCardShell(
      padding: AppSpacing.cardInsetsSm,
      color: color,
      glass: glass,
      child: child,
    );
  }
}

class _AppCardShell extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final bool glass;
  final VoidCallback? onTap;

  const _AppCardShell({
    required this.child,
    required this.padding,
    required this.color,
    required this.glass,
    this.onTap,
  });

  @override
  State<_AppCardShell> createState() => _AppCardShellState();
}

class _AppCardShellState extends State<_AppCardShell> {
  bool _pressed = false;

  bool get _interactive => widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final background =
        widget.color ??
        (widget.glass
            ? AppColors.glassSurface(context)
            : scheme.surfaceContainerLow);

    final radius = BorderRadius.circular(AppRadius.card);

    final content = AnimatedScale(
      duration: AppMotion.duration(context, AppMotion.micro),
      curve: AppMotion.standardCurve,
      scale: _pressed && _interactive ? 0.988 : 1,
      child: AnimatedContainer(
        duration: AppMotion.duration(context, AppMotion.fast),
        curve: AppMotion.standardCurve,
        decoration: BoxDecoration(
          color: background,
          borderRadius: radius,
          border: Border.all(
            color: widget.glass
                ? AppColors.glassBorder(context)
                : scheme.outlineVariant.withValues(alpha: isDark ? 0.30 : 0.38),
            width: 0.8,
          ),
          boxShadow: widget.glass
              ? AppGlassStyle.cardDecoration(context).boxShadow
              : [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isDark ? 0.15 : 0.055,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: _interactive
                ? (value) {
                    if (_pressed == value) return;
                    setState(() => _pressed = value);
                  }
                : null,
            borderRadius: radius,
            splashColor: scheme.primary.withValues(alpha: 0.06),
            highlightColor: scheme.primary.withValues(alpha: 0.035),
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );

    if (!widget.glass) {
      return content;
    }

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppGlassStyle.cardBlurSigma,
          sigmaY: AppGlassStyle.cardBlurSigma,
        ),
        child: content,
      ),
    );
  }
}
