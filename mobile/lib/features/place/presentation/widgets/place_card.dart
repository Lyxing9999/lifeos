import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../domain/enum/place_type.dart';
import '../../domain/model/place.dart';
import 'place_primary_badge.dart';
import 'place_type_chip.dart';

class PlaceCard extends StatelessWidget {
  final Place item;
  final VoidCallback onTap;

  const PlaceCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = PlaceTypeChip.typeColor(item.placeType);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.cardInsetsSm,
          child: Row(
            children: [
              Container(
                width: AppSpacing.iconContainerSize,
                height: AppSpacing.iconContainerSize,
                decoration: BoxDecoration(
                  color: AppColors.iconBg(context, color),
                  borderRadius: BorderRadius.circular(AppRadius.icon),
                ),
                child: Icon(typeIcon(item.placeType), color: color, size: 18),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTextStyles.cardTitle(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        PlaceTypeChip(type: item.placeType),
                        AppChip.metadata(
                          icon: Icons.radio_button_checked_outlined,
                          label: '${item.matchRadiusMeters.toInt()} m',
                        ),
                        if (!item.active) const PlacePrimaryBadge(),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Icon mapping per place type.
  static IconData typeIcon(PlaceType type) {
    switch (type) {
      case PlaceType.home:
        return Icons.home_outlined;
      case PlaceType.work:
        return Icons.work_outline;
      case PlaceType.school:
        return Icons.school_outlined;
      case PlaceType.gym:
        return Icons.fitness_center_outlined;
      case PlaceType.cafe:
        return Icons.local_cafe_outlined;
      case PlaceType.restaurant:
        return Icons.restaurant_outlined;
      case PlaceType.store:
        return Icons.store_outlined;
      case PlaceType.other:
        return Icons.place_outlined;
    }
  }
}
