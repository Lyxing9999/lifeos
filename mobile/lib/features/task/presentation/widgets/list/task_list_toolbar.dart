import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_icons.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../../core/widgets/app_glass_icon_button.dart';
import '../../../domain/enum/task_filter.dart';

class TaskListToolbar extends StatelessWidget {
  final TaskFilter selectedFilter;
  final ValueChanged<TaskFilter> onFilterChanged;

  const TaskListToolbar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Material(
        color: scheme.surface.withValues(alpha: 0.72),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.36),
            width: 0.8,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              for (final filter in taskPrimaryFilters)
                Expanded(
                  child: _TaskFilterPill(
                    filter: filter,
                    selected: selectedFilter == filter,
                    onTap: () => _selectFilter(filter),
                  ),
                ),
              AppGlassIconButton(
                icon: CupertinoIcons.ellipsis,
                selectedIcon: CupertinoIcons.check_mark,
                tooltip: 'More task views',
                selected: selectedFilter.isMore,
                onPressed: () => _showMoreSelector(context),
                size: 44,
                iconSize: selectedFilter.isMore ? 18 : 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectFilter(TaskFilter filter) {
    HapticFeedback.selectionClick();
    onFilterChanged(filter);
  }

  Future<void> _showMoreSelector(BuildContext context) async {
    final selected = await AppBottomSheet.show<TaskFilter>(
      context: context,
      title: 'More task views',
      subtitle: 'Open a focused workspace for task maintenance.',
      showCloseButton: true,
      child: _TaskMoreSelectorSheet(selectedFilter: selectedFilter),
    );

    if (selected == null) return;

    HapticFeedback.selectionClick();
    onFilterChanged(selected);
  }
}

class _TaskFilterPill extends StatelessWidget {
  final TaskFilter filter;
  final bool selected;
  final VoidCallback onTap;

  const _TaskFilterPill({
    required this.filter,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: selected
            ? scheme.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: selected
            ? Border.all(
                color: scheme.primary.withValues(alpha: 0.30),
                width: 0.9,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.full),
          onTap: onTap,
          splashColor: scheme.primary.withValues(alpha: 0.08),
          highlightColor: scheme.primary.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 11,
            ),
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                  letterSpacing: -0.1,
                ),
                child: Text(
                  filter.shortLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskMoreSelectorSheet extends StatelessWidget {
  final TaskFilter selectedFilter;

  const _TaskMoreSelectorSheet({required this.selectedFilter});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final filter in taskMoreFilters) ...[
          _MoreSelectorCard(
            filter: filter,
            selected: selectedFilter == filter,
            onTap: () => Navigator.of(context).pop(filter),
          ),
          if (filter != taskMoreFilters.last)
            const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _MoreSelectorCard extends StatelessWidget {
  final TaskFilter filter;
  final bool selected;
  final VoidCallback onTap;

  const _MoreSelectorCard({
    required this.filter,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _accentColor(context, filter);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 190),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected
            ? accent.withValues(alpha: isDark ? 0.12 : 0.08)
            : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
        border: Border.all(
          color: selected
              ? accent.withValues(alpha: isDark ? 0.34 : 0.30)
              : scheme.outlineVariant.withValues(alpha: 0.36),
          width: selected ? 0.9 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.055),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.cardLg),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          splashColor: accent.withValues(alpha: 0.08),
          highlightColor: accent.withValues(alpha: 0.04),
          child: Padding(
            padding: AppSpacing.cardInsets,
            child: Row(
              children: [
                Container(
                  width: AppSpacing.iconContainerSizeLg,
                  height: AppSpacing.iconContainerSizeLg,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: selected ? 0.16 : 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.iconLg),
                    border: Border.all(
                      color: accent.withValues(alpha: selected ? 0.30 : 0.18),
                      width: 0.8,
                    ),
                  ),
                  child: Icon(_icon(filter), color: accent, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        filter.label,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                              color: scheme.onSurface,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        filter.description,
                        style: AppTextStyles.bodySecondary(
                          context,
                        ).copyWith(height: 1.30),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Icon(
                  CupertinoIcons.chevron_forward,
                  size: 18,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static IconData _icon(TaskFilter filter) {
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

  static Color _accentColor(BuildContext context, TaskFilter filter) {
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
