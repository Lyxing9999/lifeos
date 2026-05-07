import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_icons.dart';
import 'fab_safe_area.dart';

class AppPageFab extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final String? heroTag;
  final bool extended;
  final String? label;

  const AppPageFab({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.heroTag,
    this.extended = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIcon = icon == Icons.add ? AppIcons.add : icon;

    return FabSafeArea(
      child: extended && (label ?? '').trim().isNotEmpty
          ? FloatingActionButton.extended(
              heroTag: heroTag,
              onPressed: onPressed == null
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      onPressed?.call();
                    },
              tooltip: tooltip,
              icon: Icon(effectiveIcon),
              label: Text(label!.trim()),
            )
          : FloatingActionButton.small(
              heroTag: heroTag,
              onPressed: onPressed == null
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      onPressed?.call();
                    },
              tooltip: tooltip,
              child: Icon(effectiveIcon),
            ),
    );
  }
}
