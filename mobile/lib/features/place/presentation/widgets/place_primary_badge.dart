import 'package:flutter/material.dart';

import '../../../../core/widgets/app_chip.dart';

class PlacePrimaryBadge extends StatelessWidget {
  const PlacePrimaryBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;

    return AppChip.status(
      label: 'Inactive',
      icon: Icons.pause_circle_outline,
      color: color,
    );
  }
}
