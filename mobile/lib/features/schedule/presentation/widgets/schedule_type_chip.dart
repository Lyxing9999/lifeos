import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/enum/schedule_block_type.dart';

class ScheduleTypeChip extends StatelessWidget {
  final ScheduleBlockType type;
  final bool selected;

  const ScheduleTypeChip({
    super.key,
    required this.type,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = typeColor(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: selected ? AppColors.chipBg(context, color) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: selected ? color : Theme.of(context).colorScheme.outline,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Text(
        type.label,
        style: AppTextStyles.chipLabel(context).copyWith(
          color: selected
              ? color
              : Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Color typeColor(ScheduleBlockType type) {
    switch (type) {
      case ScheduleBlockType.work:
        return AppColors.blue;
      case ScheduleBlockType.study:
        return AppColors.violet;
      case ScheduleBlockType.meeting:
        return AppColors.indigo;
      case ScheduleBlockType.exercise:
        return AppColors.green;
      case ScheduleBlockType.rest:
        return AppColors.teal;
      case ScheduleBlockType.commute:
        return AppColors.amber;
      case ScheduleBlockType.personal:
        return AppColors.sky;
      case ScheduleBlockType.other:
        return AppColors.slate;
    }
  }
}
