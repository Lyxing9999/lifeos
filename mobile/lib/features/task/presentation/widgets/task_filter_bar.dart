import 'package:flutter/material.dart';

import '../../domain/enum/task_filter.dart';

class TaskFilterBar extends StatelessWidget {
  final TaskFilter selected;
  final ValueChanged<TaskFilter> onChanged;
  final List<TaskFilter> filters;

  const TaskFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
    this.filters = taskPrimaryFilters,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TaskFilter>(
      showSelectedIcon: false,
      segments: filters
          .map(
            (filter) => ButtonSegment<TaskFilter>(
              value: filter,
              label: Text(
                filter.label,
                key: Key('task-filter-${filter.name}'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      selected: {selected},
      onSelectionChanged: (values) {
        if (values.isEmpty) return;
        onChanged(values.first);
      },
    );
  }
}
