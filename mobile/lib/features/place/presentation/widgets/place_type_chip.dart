import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../domain/enum/place_type.dart';

class PlaceTypeChip extends StatelessWidget {
  final PlaceType type;
  final bool selected;

  const PlaceTypeChip({super.key, required this.type, this.selected = false});

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(type);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.34,
      ),
      child: selected
          ? AppChip.filter(label: type.label, color: color, selected: true)
          : AppChip.metadata(label: type.label, color: color),
    );
  }

  static Color typeColor(PlaceType type) {
    return _typeColor(type);
  }

  static Color _typeColor(PlaceType type) {
    switch (type) {
      case PlaceType.home:
        return AppColors.green;
      case PlaceType.work:
        return AppColors.blue;
      case PlaceType.school:
        return AppColors.sky;
      case PlaceType.gym:
        return AppColors.amber;
      case PlaceType.cafe:
        return AppColors.indigo;
      case PlaceType.restaurant:
        return AppColors.indigo;
      case PlaceType.store:
        return AppColors.teal;
      case PlaceType.other:
        return AppColors.slate;
    }
  }
}
