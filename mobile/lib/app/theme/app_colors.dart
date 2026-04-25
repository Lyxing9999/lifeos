import 'package:flutter/material.dart';

/// LifeOS semantic color roles.
///
/// Roles:
/// - Blue: navigation and app accent
/// - Violet: schedule and structure
/// - Green: completion and success
/// - Amber: warning, score caution, spending, insights
/// - Indigo/Sky: places and location context
/// - Slate: neutral and meta
abstract final class AppColors {
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF38BDF8);

  static const Color violet = Color(0xFF8B5CF6);
  static const Color blue = Color(0xFF3B82F6);
  static const Color indigo = Color(0xFF4F46E5);
  static const Color green = Color(0xFF10B981);
  static const Color pink = Color(0xFFEC4899);
  static const Color sky = Color(0xFF38BDF8);
  static const Color amber = Color(0xFFF59E0B);
  static const Color teal = Color(0xFF14B8A6);
  static const Color slate = Color(0xFF94A3B8);

  static Color scoreColor(int score) {
    if (score >= 80) return success;
    if (score >= 50) return warning;
    return danger;
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

  static Color successSubtle(BuildContext context) => chipBg(context, success);
  static Color warningSubtle(BuildContext context) => chipBg(context, warning);
  static Color dangerSubtle(BuildContext context) => chipBg(context, danger);
  static Color infoSubtle(BuildContext context) => chipBg(context, info);

  static Color scoreSubtle(BuildContext context, int score) =>
      chipBg(context, scoreColor(score));

  static Color placeTypeIconColor(String typeLabel) {
    switch (typeLabel.toLowerCase()) {
      case 'home':
        return green;
      case 'work':
      case 'office':
        return blue;
      case 'gym':
        return amber;
      case 'cafe':
        return indigo;
      case 'study':
      case 'library':
        return violet;
      case 'travel':
        return sky;
      default:
        return slate;
    }
  }

  static Color placeTypeColor(BuildContext context, String typeLabel) =>
      iconBg(context, placeTypeIconColor(typeLabel));

  static Color scheduleTypeColor(String typeLabel) {
    switch (typeLabel.toLowerCase()) {
      case 'work':
        return blue;
      case 'study':
        return violet;
      case 'meeting':
        return indigo;
      case 'exercise':
        return green;
      case 'rest':
        return teal;
      case 'commute':
        return amber;
      case 'personal':
        return sky;
      default:
        return slate;
    }
  }

  static Color timelineTypeColor(BuildContext context, String type) {
    switch (type.toLowerCase()) {
      case 'task':
        return green;
      case 'schedule':
      case 'block':
        return violet;
      case 'location':
      case 'stay':
        return indigo;
      case 'financial':
      case 'purchase':
        return amber;
      case 'meeting':
        return indigo;
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
