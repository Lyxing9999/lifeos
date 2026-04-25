import 'package:flutter/material.dart';

/// LifeOS shadow system — single source of truth for all elevation shadows.
/// Shadows adapt to brightness — dark themes use deeper blacks,
/// light themes use softer greys.
abstract final class AppShadows {
  // ── Card shadows ──────────────────────────────────────────────────────────

  /// Subtle lift — standard card on a page
  static List<BoxShadow> card(bool isDark) => [
    BoxShadow(
      color: isDark
          ? Colors.black.withValues(alpha: 0.30)
          : Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      spreadRadius: -2,
      offset: const Offset(0, 4),
    ),
  ];

  /// Medium lift — floating sheets, bottom sheets
  static List<BoxShadow> sheet(bool isDark) => [
    BoxShadow(
      color: isDark
          ? Colors.black.withValues(alpha: 0.40)
          : Colors.black.withValues(alpha: 0.10),
      blurRadius: 24,
      spreadRadius: -4,
      offset: const Offset(0, 8),
    ),
  ];

  // ── Liquid Glass shadows ──────────────────────────────────────────────────
  // Two-layer shadow: depth shadow + primary color ambient glow.

  /// Floating pill nav bar shadow
  static List<BoxShadow> navPill(bool isDark) => [
    BoxShadow(
      color: isDark
          ? Colors.black.withValues(alpha: 0.45)
          : Colors.black.withValues(alpha: 0.14),
      blurRadius: 32,
      spreadRadius: -4,
      offset: const Offset(0, 8),
    ),
    // Inner top-edge glow — simulates light refraction through glass
    BoxShadow(
      color: isDark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.white.withValues(alpha: 0.30),
      blurRadius: 1,
      spreadRadius: 0,
      offset: const Offset(0, 1),
    ),
  ];

  /// AI summary card / hero glass card shadow
  static List<BoxShadow> glassCard(bool isDark, Color primary) => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.55)
              : Colors.black.withValues(alpha: 0.13),
          blurRadius: 36,
          spreadRadius: -8,
          offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.22)
              : Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          spreadRadius: -2,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: primary.withValues(alpha: isDark ? 0.10 : 0.07),
          blurRadius: 48,
          spreadRadius: -12,
          offset: const Offset(0, 18),
        ),
      ];
}
