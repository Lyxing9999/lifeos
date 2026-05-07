import 'dart:ui';

import 'package:flutter/material.dart';

class BootstrapGlassCard extends StatelessWidget {
  final Widget child;
  final double width;
  final EdgeInsetsGeometry padding;

  const BootstrapGlassCard({
    super.key,
    required this.child,
    this.width = 304,
    this.padding = const EdgeInsets.fromLTRB(24, 28, 24, 24),
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          width: width,
          padding: padding,
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: isDark ? 0.58 : 0.72),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.38),
              width: 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.10),
                blurRadius: 34,
                offset: const Offset(0, 18),
              ),
              BoxShadow(
                color: scheme.primary.withValues(alpha: isDark ? 0.08 : 0.10),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
