import 'package:flutter/material.dart';

enum TaskListFilter { active, completed, all }

extension TaskListFilterX on TaskListFilter {
  String get apiValue {
    switch (this) {
      case TaskListFilter.active:
        return 'ACTIVE';
      case TaskListFilter.completed:
        return 'COMPLETED';
      case TaskListFilter.all:
        return 'ALL';
    }
  }

  String get label {
    switch (this) {
      case TaskListFilter.active:
        return 'Active';
      case TaskListFilter.completed:
        return 'Completed';
      case TaskListFilter.all:
        return 'All';
    }
  }
}

class TaskFilterBar extends StatelessWidget {
  final TaskListFilter selected;
  final ValueChanged<TaskListFilter> onChanged;

  const TaskFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TaskListFilter>(
      segments: TaskListFilter.values
          .map(
            (filter) => ButtonSegment<TaskListFilter>(
              value: filter,
              label: Text(filter.label),
            ),
          )
          .toList(),
      selected: {selected},
      onSelectionChanged: (values) => onChanged(values.first),
    );
  }
}
