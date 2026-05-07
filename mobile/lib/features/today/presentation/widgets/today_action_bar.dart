import 'package:flutter/material.dart';

import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

class TodayActionBar extends StatelessWidget {
  final bool compact;
  final VoidCallback onAddTaskTap;
  final VoidCallback onAddScheduleTap;
  final VoidCallback onTasksTap;
  final VoidCallback onScheduleTap;

  const TodayActionBar({
    super.key,
    required this.compact,
    required this.onAddTaskTap,
    required this.onAddScheduleTap,
    required this.onTasksTap,
    required this.onScheduleTap,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Row(
        children: [
          Expanded(
            child: AppButton.primary(
              label: 'Add task',
              icon: AppIcons.addTask,
              onPressed: onAddTaskTap,
              fullWidth: true,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppButton.secondary(
              label: 'Plan time',
              icon: AppIcons.schedule,
              onPressed: onAddScheduleTap,
              fullWidth: true,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Start your day', style: AppTextStyles.sectionHeader(context)),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: AppIcons.addTask,
                label: 'Add task',
                onTap: onAddTaskTap,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _ActionButton(
                icon: AppIcons.schedule,
                label: 'Plan time',
                onTap: onAddScheduleTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: AppIcons.tasks,
                label: 'Tasks',
                onTap: onTasksTap,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _ActionButton(
                icon: AppIcons.schedule,
                label: 'Schedule',
                onTap: onScheduleTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton.secondary(
      label: label,
      icon: icon,
      onPressed: onTap,
      fullWidth: true,
    );
  }
}
