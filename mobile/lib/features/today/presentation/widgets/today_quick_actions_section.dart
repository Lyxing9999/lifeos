import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class TodayQuickActionsSection extends StatelessWidget {
  final VoidCallback onAddTaskTap;
  final VoidCallback onAddScheduleTap;
  final VoidCallback onTasksTap;
  final VoidCallback onScheduleTap;

  const TodayQuickActionsSection({
    super.key,
    required this.onAddTaskTap,
    required this.onAddScheduleTap,
    required this.onTasksTap,
    required this.onScheduleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTextStyles.sectionHeader(context)),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.add_task_outlined,
                label: 'Add task',
                onTap: onAddTaskTap,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.event_available_outlined,
                label: 'Add schedule',
                onTap: onAddScheduleTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.checklist_outlined,
                label: 'Open tasks',
                onTap: onTasksTap,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.calendar_month_outlined,
                label: 'Open schedule',
                onTap: onScheduleTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
    );
  }
}
