import 'package:flutter/material.dart';

/// Single canonical AppThemePalette used by AppTheme.
/// Includes both base colors and semantic colors.
class AppThemePalette {
  final Brightness brightness;
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color error;

  // Semantic colors — used by AppColors
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;

  const AppThemePalette({
    required this.brightness,
    required this.primary,
    required this.secondary,
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
}
