import 'package:flutter/material.dart';

/// LifeOS spacing system — 4pt grid.
///
/// Use these tokens everywhere.
/// Avoid magic numbers in widgets unless the value is truly one-off.
abstract final class AppSpacing {
  // Base scale
  static const double zero = 0;
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // Page layout
  static const double pageHorizontal = 16;
  static const double pageVertical = 8;

  // Components
  static const double cardPadding = 16;
  static const double cardPaddingSm = 12;
  static const double listItemGap = 8;
  static const double sectionGap = 16;
  static const double iconContainerSize = 36;
  static const double iconContainerSizeLg = 44;
  static const double avatarRadius = 28;
  static const double minTapTarget = 48;

  // Backward-compatible aliases
  static const double cardRadius = 16;
  static const double chipRadius = 8;
  static const double iconContainerRadius = 8;

  // Bottom nav dimensions
  static const double bottomNavHeight = 64;
  static const double bottomNavHorizontalMargin = 16;
  static const double bottomNavBottomMarginNoInset = 8;
  static const double bottomNavBottomMarginWithInset = 4;

  /// Dynamic bottom clearance for scrollable tab pages.
  ///
  /// Accounts for:
  /// - floating glass nav height
  /// - bottom outer margin
  /// - device home indicator
  /// - breathing room above the nav
  static double navBarClearance(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return bottomNavHeight +
        (bottomInset == 0
            ? bottomNavBottomMarginNoInset
            : bottomNavBottomMarginWithInset) +
        bottomInset +
        8;
  }

  /// Static fallback for const contexts.
  static const double navBarClearanceFallback = 112;

  // EdgeInsets helpers
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: pageHorizontal,
    vertical: pageVertical,
  );

  static const EdgeInsets pagePaddingHorizontal = EdgeInsets.symmetric(
    horizontal: pageHorizontal,
  );

  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);

  static const EdgeInsets cardInsetsSm = EdgeInsets.all(cardPaddingSm);

  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets horizontalPage = EdgeInsets.symmetric(
    horizontal: pageHorizontal,
  );

  static const EdgeInsets chipInsets = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 4,
  );

  static const EdgeInsets chipInsetsLg = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 7,
  );

  static const EdgeInsets bottomSheetInsets = EdgeInsets.fromLTRB(
    lg,
    md,
    lg,
    xl,
  );
}
