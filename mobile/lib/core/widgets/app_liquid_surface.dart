import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_glass_style.dart';

enum AppLiquidSurfaceVariant { floating, modal }

class AppLiquidSurface extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final AppLiquidSurfaceVariant variant;
  final Color? accentColor;
  final EdgeInsetsGeometry padding;
  final double? blurSigma;
  final bool showHighlight;

  const AppLiquidSurface({
    super.key,
    required this.child,
    required this.borderRadius,
    required this.variant,
    this.accentColor,
    this.padding = EdgeInsets.zero,
    this.blurSigma,
    this.showHighlight = true,
  });

  @override
  Widget build(BuildContext context) {
    final sigma =
        blurSigma ??
        switch (variant) {
          AppLiquidSurfaceVariant.floating => AppGlassStyle.toastBlurSigma,
          AppLiquidSurfaceVariant.modal => AppGlassStyle.modalBlurSigma,
        };

    final decoration = switch (variant) {
      AppLiquidSurfaceVariant.floating => AppGlassStyle.floatingDecoration(
        context,
        borderRadius: borderRadius,
        accentColor: accentColor,
      ),
      AppLiquidSurfaceVariant.modal => AppGlassStyle.modalDecoration(
        context,
        borderRadius: borderRadius,
        accentColor: accentColor,
      ),
    };

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: DecoratedBox(
          decoration: decoration,
          child: Stack(
            children: [
              if (showHighlight)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: borderRadius,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.glassHighlight(context),
                            Colors.transparent,
                            (accentColor ?? Colors.transparent).withValues(
                              alpha: accentColor == null ? 0 : 0.035,
                            ),
                          ],
                          stops: const [0, 0.48, 1],
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}
