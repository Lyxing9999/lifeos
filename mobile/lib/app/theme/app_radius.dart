/// LifeOS radius system — single source of truth for all border radii.
/// No widget should define its own BorderRadius.circular(x) with a magic number.
abstract final class AppRadius {
  /// Standard card / sheet / input radius
  static const double card = 16;

  /// Large card — used for hero cards, AI summary, score hero
  static const double cardLg = 24;

  /// Small chip / badge radius
  static const double chip = 12;

  /// Icon container radius
  static const double icon = 10;

  /// Pill / FAB / nav bar radius
  static const double pill = 28;

  /// Tiny badge radius
  static const double badge = 6;

  /// Full circle (use with a square container)
  static const double full = 999;
}
