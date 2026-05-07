import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

/// Wraps a FAB with correct bottom padding when used inside a shell page

/// with `Scaffold.extendBody = true`.

///

/// Use when the page also has the floating glass bottom nav.

class FabSafeArea extends StatelessWidget {
  final Widget child;

  /// Extra breathing room above the bottom nav.

  final double extra;

  const FabSafeArea({super.key, required this.child, this.extra = 8});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: AppSpacing.navBarClearance(context) + extra,
      ),

      child: child,
    );
  }
}
