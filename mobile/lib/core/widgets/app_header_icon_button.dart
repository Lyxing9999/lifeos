import 'package:flutter/material.dart';

import 'app_glass_icon_button.dart';

class AppHeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool selected;

  const AppHeaderIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppGlassIconButton(
      icon: icon,
      tooltip: tooltip,
      onPressed: onPressed,
      selected: selected,
    );
  }
}
