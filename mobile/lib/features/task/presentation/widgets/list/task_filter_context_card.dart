import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_icons.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_shadows.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../domain/enum/task_filter.dart';

class TaskFilterContextCard extends StatelessWidget {
  final TaskFilter filter;
  final int count;
  final VoidCallback onBackToDue;

  const TaskFilterContextCard({
    super.key,
    required this.filter,
    required this.count,
    required this.onBackToDue,
  });

  @override
  Widget build(BuildContext context) {
    if (filter.isPrimary) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _color(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.cardLg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: isDark ? 0.62 : 0.82),
            borderRadius: BorderRadius.circular(AppRadius.cardLg),
            border: Border.all(
              color: accent.withValues(alpha: isDark ? 0.28 : 0.22),
              width: 0.9,
            ),
            boxShadow: AppShadows.card(isDark),
          ),
          child: Padding(
            padding: AppSpacing.cardInsets,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _ContextIcon(icon: _icon, color: accent),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _ContextText(
                    title: _title,
                    description: _description,
                    count: count,
                    color: accent,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _DueButton(onPressed: onBackToDue),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _title {
    switch (filter) {
      case TaskFilter.all:
        return 'Task library';
      case TaskFilter.paused:
        return 'Paused tasks';
      case TaskFilter.history:
        return 'Task history';
      case TaskFilter.archive:
        return 'Archived tasks';
      case TaskFilter.due:
        return 'Due';
      case TaskFilter.inbox:
        return 'Inbox';
      case TaskFilter.done:
        return 'Done';
    }
  }

  String get _description {
    switch (filter) {
      case TaskFilter.all:
        return 'Active task intentions. Open a task to manage its plan.';
      case TaskFilter.paused:
        return 'Tasks stopped for now. Open one to resume it.';
      case TaskFilter.history:
        return 'Completed task history for the selected day.';
      case TaskFilter.archive:
        return 'Hidden tasks you can restore or permanently delete.';
      case TaskFilter.due:
        return 'Tasks needing time attention.';
      case TaskFilter.inbox:
        return 'Captured tasks not planned yet.';
      case TaskFilter.done:
        return 'Completed tasks ready for review.';
    }
  }

  IconData get _icon {
    switch (filter) {
      case TaskFilter.all:
        return AppIcons.tasks;
      case TaskFilter.paused:
        return AppIcons.paused;
      case TaskFilter.history:
        return AppIcons.history;
      case TaskFilter.archive:
        return AppIcons.archive;
      case TaskFilter.due:
        return AppIcons.date;
      case TaskFilter.inbox:
        return AppIcons.inbox;
      case TaskFilter.done:
        return AppIcons.complete;
    }
  }

  Color _color(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    switch (filter) {
      case TaskFilter.all:
        return scheme.primary;
      case TaskFilter.paused:
        return AppColors.amber;
      case TaskFilter.history:
        return AppColors.indigo;
      case TaskFilter.archive:
        return scheme.onSurfaceVariant;
      case TaskFilter.due:
        return scheme.primary;
      case TaskFilter.inbox:
        return scheme.tertiary;
      case TaskFilter.done:
        return AppColors.green;
    }
  }
}

class _ContextIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _ContextIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.iconContainerSizeLg,
      height: AppSpacing.iconContainerSizeLg,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.iconLg),
        border: Border.all(color: color.withValues(alpha: 0.18), width: 0.8),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _ContextText extends StatelessWidget {
  final String title;
  final String description;
  final int count;
  final Color color;

  const _ContextText({
    required this.title,
    required this.description,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final taskLabel = count == 1 ? 'task' : 'tasks';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.cardTitle(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          description,
          style: AppTextStyles.bodySecondary(context),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '$count $taskLabel',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.05,
          ),
        ),
      ],
    );
  }
}

class _DueButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _DueButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: AppButton.ghost(label: 'Due', onPressed: onPressed),
    );
  }
}
