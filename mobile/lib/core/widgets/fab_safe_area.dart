import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';

/// Wraps a FAB with correct bottom padding when used inside a page
/// that lives inside the shell with extendBody: true.
///
/// Accounts for the floating pill nav bar height (64) + pill bottom padding (12)
/// + device home indicator + breathing room.
///
/// Usage:
///   floatingActionButton: FabSafeArea(child: FloatingActionButton.extended(...))
class FabSafeArea extends StatelessWidget {
  final Widget child;

  /// Extra padding above the nav bar. Default 8px breathing room.
  final double extra;

  const FabSafeArea({
    super.key,
    required this.child,
    this.extra = 8,
  });

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
