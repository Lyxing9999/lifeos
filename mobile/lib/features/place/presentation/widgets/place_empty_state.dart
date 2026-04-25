import 'package:flutter/material.dart';

import '../../../../core/widgets/app_empty_view.dart';

class PlaceEmptyState extends StatelessWidget {
  final VoidCallback? onCreatePlace;

  const PlaceEmptyState({super.key, this.onCreatePlace});

  @override
  Widget build(BuildContext context) {
    return AppEmptyView(
      icon: Icons.place_outlined,
      title: 'No saved places yet',
      subtitle:
          'Save places like Home, Work, or Gym so stay sessions can match them.',
      actionLabel: onCreatePlace == null ? null : 'Create place',
      actionIcon: Icons.place,
      onAction: onCreatePlace,
    );
  }
}
