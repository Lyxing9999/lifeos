import 'package:flutter/material.dart';

/// LifeOS spacing system — 4pt grid.
/// Use these tokens everywhere. No magic numbers in widgets.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // Semantic layout constants
  static const double pageHorizontal = 16;
  static const double pageVertical = 8;
  static const double cardPadding = 16;
  static const double cardPaddingSm = 12;
  static const double listItemGap = 8;
  static const double sectionGap = 16;
  static const double cardRadius = 16;
  static const double chipRadius = 8;
  static const double iconContainerSize = 36;
  static const double iconContainerRadius = 8;
  static const double avatarRadius = 28;
  static const double minTapTarget = 48;

  /// Dynamic bottom clearance for scrollable tab pages.
  /// Accounts for the floating pill nav bar height (56) + bottom padding (12)
  /// + device home indicator + breathing room.
  static double navBarClearance(BuildContext context) =>
      56.0 + 12.0 + MediaQuery.of(context).padding.bottom + 16.0;

  /// Static fallback for const contexts — use navBarClearance(context) when possible.
  static const double navBarClearanceFallback = 110;

  // EdgeInsets helpers
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: pageHorizontal,
    vertical: pageVertical,
  );
  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);
  static const EdgeInsets cardInsetsSm = EdgeInsets.all(cardPaddingSm);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets chipInsets = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 4,
  );
}
