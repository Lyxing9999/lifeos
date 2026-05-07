import 'package:flutter/material.dart';

abstract final class AppColors {
  // Semantic colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF38BDF8);

  // Accent palette
  static const Color violet = Color(0xFF8B5CF6);
  static const Color blue = Color(0xFF3B82F6);
  static const Color indigo = Color(0xFF4F46E5);
  static const Color green = Color(0xFF10B981);
  static const Color pink = Color(0xFFEC4899);
  static const Color sky = Color(0xFF38BDF8);
  static const Color amber = Color(0xFFF59E0B);
  static const Color teal = Color(0xFF14B8A6);
  static const Color slate = Color(0xFF94A3B8);

  // Neutral helpers
  static const Color black = Color(0xFF020617);
  static const Color white = Color(0xFFFFFFFF);

  static Color scoreColor(int score) {
    if (score >= 80) return success;
    if (score >= 50) return warning;
    return danger;
  }

  static Color priorityColor(String value) {
    switch (value.trim().toLowerCase()) {
      case 'urgent':
      case 'high':
        return danger;
      case 'medium':
        return warning;
      case 'low':
        return info;
      default:
        return slate;
    }
  }

  static Color taskModeColor(String value) {
    switch (value.trim().toLowerCase()) {
      case 'urgent':
        return danger;
      case 'daily':
        return green;
      case 'progress':
        return violet;
      case 'standard':
        return blue;
      default:
        return slate;
    }
  }

  static Color iconBg(BuildContext context, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return color.withValues(alpha: isDark ? 0.20 : 0.12);
  }

  static Color chipBg(BuildContext context, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return color.withValues(alpha: isDark ? 0.16 : 0.10);
  }

  static Color cellBg(BuildContext context, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return color.withValues(alpha: isDark ? 0.14 : 0.08);
  }

  static Color borderFor(BuildContext context, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return color.withValues(alpha: isDark ? 0.28 : 0.18);
  }

  static Color shadowFor(BuildContext context, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return color.withValues(alpha: isDark ? 0.13 : 0.08);
  }

  static Color glassSurface(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return scheme.surface.withValues(alpha: isDark ? 0.64 : 0.82);
  }

  static Color glassBorder(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return scheme.outlineVariant.withValues(alpha: isDark ? 0.30 : 0.40);
  }

  static Color glassHighlight(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Color.lerp(
      scheme.surface,
      Colors.white,
      isDark ? 0.10 : 0.56,
    )!.withValues(alpha: isDark ? 0.10 : 0.18);
  }

  static Color liquidControl(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return scheme.surfaceContainerHighest.withValues(
      alpha: isDark ? 0.42 : 0.66,
    );
  }

  static Color successSubtle(BuildContext context) {
    return chipBg(context, success);
  }

  static Color warningSubtle(BuildContext context) {
    return chipBg(context, warning);
  }

  static Color dangerSubtle(BuildContext context) {
    return chipBg(context, danger);
  }

  static Color infoSubtle(BuildContext context) {
    return chipBg(context, info);
  }

  static Color scoreSubtle(BuildContext context, int score) {
    return chipBg(context, scoreColor(score));
  }

  static Color placeTypeIconColor(String typeLabel) {
    switch (typeLabel.trim().toLowerCase()) {
      case 'home':
        return green;
      case 'work':
      case 'office':
        return blue;
      case 'gym':
      case 'exercise':
      case 'fitness':
        return amber;
      case 'cafe':
      case 'coffee':
        return indigo;
      case 'study':
      case 'library':
      case 'school':
        return violet;
      case 'travel':
      case 'airport':
      case 'station':
        return sky;
      case 'shop':
      case 'shopping':
      case 'mall':
        return pink;
      default:
        return slate;
    }
  }

  static Color placeTypeColor(BuildContext context, String typeLabel) {
    return iconBg(context, placeTypeIconColor(typeLabel));
  }

  static Color scheduleTypeColor(String typeLabel) {
    switch (typeLabel.trim().toLowerCase()) {
      case 'work':
        return blue;
      case 'study':
      case 'learning':
        return violet;
      case 'meeting':
        return indigo;
      case 'exercise':
      case 'workout':
      case 'fitness':
        return green;
      case 'rest':
      case 'sleep':
      case 'recovery':
        return teal;
      case 'commute':
      case 'travel':
        return amber;
      case 'personal':
        return sky;
      case 'meal':
      case 'food':
        return pink;
      default:
        return slate;
    }
  }

  static Color timelineTypeColor(BuildContext context, String type) {
    switch (type.trim().toLowerCase()) {
      case 'task':
        return green;
      case 'schedule':
      case 'block':
        return violet;
      case 'location':
      case 'stay':
      case 'place':
        return indigo;
      case 'financial':
      case 'purchase':
      case 'money':
        return amber;
      case 'meeting':
        return indigo;
      case 'health':
      case 'exercise':
        return green;
      default:
        return slate;
    }
  }

  static Color locationHourColor(int hour) {
    if (hour < 6) return violet;
    if (hour < 12) return amber;
    if (hour < 17) return blue;
    if (hour < 21) return teal;
    return slate;
  }
}
