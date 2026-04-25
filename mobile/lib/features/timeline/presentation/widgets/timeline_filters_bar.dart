import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_chip.dart';

enum TimelineFilter { all, schedule, tasks, places, spending }

class TimelineFiltersBar extends StatelessWidget {
  final TimelineFilter selected;
  final ValueChanged<TimelineFilter> onChanged;

  const TimelineFiltersBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _filters = [
    (TimelineFilter.all, 'All'),
    (TimelineFilter.schedule, 'Schedule'),
    (TimelineFilter.tasks, 'Tasks'),
    (TimelineFilter.places, 'Stay sessions'),
    (TimelineFilter.spending, 'Spending'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: _filters.length,
        separatorBuilder: (_, index) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final (filter, label) = _filters[index];
          return _FilterChip(
            label: label,
            selected: selected == filter,
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(filter);
            },
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return AppChip.filter(
      label: label,
      color: color,
      selected: selected,
      onTap: onTap,
    );
  }
}
