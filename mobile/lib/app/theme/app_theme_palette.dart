import 'package:flutter/material.dart';

/// Single canonical LifeOS theme palette.
///
/// This is the raw color source used by AppThemeFactory.
/// Keep this simple: no BuildContext, no ThemeData logic here.
class AppThemePalette {
  final Brightness brightness;

  // Brand / accent colors
  final Color primary;
  final Color secondary;
  final Color tertiary;

  // Surface colors
  final Color background;
  final Color surface;
  final Color surfaceVariant;

  // Text colors
  final Color textPrimary;
  final Color textSecondary;

  // System / semantic colors
  final Color error;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;

  const AppThemePalette({
    required this.brightness,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.error,
    this.success = const Color(0xFF10B981),
    this.warning = const Color(0xFFF59E0B),
    this.danger = const Color(0xFFEF4444),
    this.info = const Color(0xFF0EA5E9),
  });

  bool get isDark => brightness == Brightness.dark;
  bool get isLight => brightness == Brightness.light;
}
