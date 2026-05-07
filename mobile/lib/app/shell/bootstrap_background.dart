import 'dart:ui';

import 'package:flutter/material.dart';

class BootstrapBackground extends StatelessWidget {
  final Widget child;

  const BootstrapBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.surface,
                  scheme.surfaceContainerHighest.withValues(alpha: 0.92),
                  scheme.primaryContainer.withValues(
                    alpha: isDark ? 0.18 : 0.34,
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -90,
          right: -80,
          child: _SoftGlow(
            size: 230,
            color: scheme.primary.withValues(alpha: isDark ? 0.18 : 0.22),
          ),
        ),
        Positioned(
          bottom: -110,
          left: -90,
          child: _SoftGlow(
            size: 260,
            color: scheme.tertiary.withValues(alpha: isDark ? 0.14 : 0.20),
          ),
        ),
        Positioned(
          top: 180,
          left: -70,
          child: _SoftGlow(
            size: 150,
            color: scheme.secondary.withValues(alpha: isDark ? 0.08 : 0.13),
          ),
        ),
        SafeArea(child: child),
      ],
    );
  }
}

class _SoftGlow extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftGlow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 46, sigmaY: 46),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
