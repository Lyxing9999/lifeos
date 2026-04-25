import 'package:flutter/material.dart';

import 'fab_safe_area.dart';

class AppPageFab extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final String? heroTag;

  const AppPageFab({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return FabSafeArea(
      child: FloatingActionButton.small(
        heroTag: heroTag,
        onPressed: onPressed,
        tooltip: tooltip,
        child: Icon(icon),
      ),
    );
  }
}
