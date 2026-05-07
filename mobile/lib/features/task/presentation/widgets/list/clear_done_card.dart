import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_icons.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../content/task_copy.dart';
import '../../style/task_style.dart';

class ClearDoneCard extends StatelessWidget {
  final int count;
  final bool isSaving;
  final VoidCallback onClear;

  const ClearDoneCard({
    super.key,
    required this.count,
    required this.isSaving,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final color = TaskStyle.completedColor();
    final taskLabel = count == 1 ? 'task' : 'tasks';

    return AppCard(
      glass: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ClearDoneIcon(color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count done $taskLabel reviewed',
                  style: AppTextStyles.cardTitle(context),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Clear Done to calm this view. History and Timeline stay intact.',
                  style: AppTextStyles.bodySecondary(context),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          AppButton.secondary(
            label: TaskCopy.clearDoneAction,
            icon: AppIcons.check,
            isLoading: isSaving,
            onPressed: isSaving ? null : onClear,
          ),
        ],
      ),
    );
  }
}

class _ClearDoneIcon extends StatelessWidget {
  final Color color;

  const _ClearDoneIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.chipBg(context, color),
        borderRadius: BorderRadius.circular(AppRadius.iconLg),
        border: Border.all(color: AppColors.borderFor(context, color)),
      ),
      child: SizedBox(
        width: 42,
        height: 42,
        child: Icon(AppIcons.complete, color: color, size: 22),
      ),
    );
  }
}
