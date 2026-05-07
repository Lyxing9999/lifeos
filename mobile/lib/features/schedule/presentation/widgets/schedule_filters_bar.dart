import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../content/schedule_copy.dart';
import '../../domain/enum/schedule_view_filter.dart';

class ScheduleFiltersBar extends StatelessWidget {
  final ScheduleViewFilter selected;
  final ValueChanged<ScheduleViewFilter> onChanged;

  const ScheduleFiltersBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _filters = [
    (ScheduleViewFilter.all, ScheduleCopy.filterAll),
    (ScheduleViewFilter.work, ScheduleCopy.filterWork),
    (ScheduleViewFilter.study, ScheduleCopy.filterStudy),
    (ScheduleViewFilter.personal, ScheduleCopy.filterPersonal),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
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
    return AppChip.filter(
      label: label,
      color: Theme.of(context).colorScheme.primary,
      selected: selected,
      onTap: onTap,
    );
  }
}
