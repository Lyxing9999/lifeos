import 'package:flutter/material.dart';

/// LifeOS shadow system.
///
/// Single source of truth for reusable elevation shadows.
/// Keep shadows soft. Motion and layout should explain hierarchy more than heavy elevation.
abstract final class AppShadows {
  /// Subtle lift — standard card on a page.
  static List<BoxShadow> card(bool isDark) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.055),
        blurRadius: 12,
        spreadRadius: -3,
        offset: const Offset(0, 5),
      ),
    ];
  }

  /// Slightly stronger lift — interactive cards and selected cards.
  static List<BoxShadow> cardSelected(bool isDark, Color accent) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.075),
        blurRadius: 16,
        spreadRadius: -4,
        offset: const Offset(0, 7),
      ),
      BoxShadow(
        color: accent.withValues(alpha: isDark ? 0.08 : 0.06),
        blurRadius: 18,
        spreadRadius: -6,
        offset: const Offset(0, 8),
      ),
    ];
  }

  /// Medium lift — modal sheets and floating surfaces.
  static List<BoxShadow> sheet(bool isDark) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.34 : 0.12),
        blurRadius: 28,
        spreadRadius: -6,
        offset: const Offset(0, 14),
      ),
    ];
  }

  /// Floating pill nav bar shadow.
  static List<BoxShadow> navPill(bool isDark) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.12),
        blurRadius: 26,
        spreadRadius: -4,
        offset: const Offset(0, 12),
      ),
    ];
  }

  /// Glass card / hero surface shadow.
  static List<BoxShadow> glassCard(bool isDark, Color primary) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.26 : 0.10),
        blurRadius: 30,
        spreadRadius: -8,
        offset: const Offset(0, 14),
      ),
      BoxShadow(
        color: primary.withValues(alpha: isDark ? 0.05 : 0.07),
        blurRadius: 22,
        spreadRadius: -8,
        offset: const Offset(0, 6),
      ),
    ];
  }

  /// App header / top translucent bar shadow.
  static List<BoxShadow> header(bool isDark) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.035),
        blurRadius: 14,
        spreadRadius: -6,
        offset: const Offset(0, 6),
      ),
    ];
  }

  /// Small floating controls like header icon buttons.
  static List<BoxShadow> control(bool isDark) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.055),
        blurRadius: 10,
        spreadRadius: -4,
        offset: const Offset(0, 4),
      ),
    ];
  }

  /// No shadow.
  static const List<BoxShadow> none = <BoxShadow>[];
}
