import 'package:flutter/material.dart';

import '../../../../app/theme/app_icons.dart';
import '../../../../core/widgets/app_empty_view.dart';

class PlaceEmptyState extends StatelessWidget {
  final VoidCallback? onCreatePlace;

  const PlaceEmptyState({super.key, this.onCreatePlace});

  @override
  Widget build(BuildContext context) {
    return AppEmptyView(
      icon: AppIcons.places,
      title: 'No saved places yet',
      subtitle:
          'Save places like Home, Work, or Gym so stay sessions can match them.',
      actionLabel: onCreatePlace == null ? null : 'Create place',
      actionIcon: AppIcons.place,
      onAction: onCreatePlace,
    );
  }
}
