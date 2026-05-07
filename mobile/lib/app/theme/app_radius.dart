/// LifeOS radius system.
///
/// Single source of truth for all border radii.
/// Avoid magic numbers like `BorderRadius.circular(17)` inside widgets.
abstract final class AppRadius {
  /// Standard card / input / picker tile radius.
  static const double card = 16;

  /// Large cards, sheets, page clusters, hero surfaces.
  static const double cardLg = 24;

  /// Extra-large modal/sheet radius.
  static const double sheet = 28;

  /// Small chip / compact badge radius.
  static const double chip = 12;

  /// Icon container radius.
  static const double icon = 10;

  /// Larger icon tile radius.
  static const double iconLg = 14;

  /// Pill / FAB / segmented control / nav item radius.
  static const double pill = 28;

  /// Tiny badge radius.
  static const double badge = 6;

  /// Full circle / stadium.
  static const double full = 999;
}
