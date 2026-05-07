enum TaskFilter { due, inbox, done, all, paused, history, archive }

extension TaskFilterX on TaskFilter {
  String get label {
    switch (this) {
      case TaskFilter.due:
        return 'Due';
      case TaskFilter.inbox:
        return 'Inbox';
      case TaskFilter.done:
        return 'Done';
      case TaskFilter.all:
        return 'Task library';
      case TaskFilter.paused:
        return 'Paused';
      case TaskFilter.history:
        return 'History';
      case TaskFilter.archive:
        return 'Archived';
    }
  }

  String get shortLabel {
    switch (this) {
      case TaskFilter.due:
        return 'Due';
      case TaskFilter.inbox:
        return 'Inbox';
      case TaskFilter.done:
        return 'Done';
      case TaskFilter.all:
        return 'All';
      case TaskFilter.paused:
        return 'Paused';
      case TaskFilter.history:
        return 'History';
      case TaskFilter.archive:
        return 'Archive';
    }
  }

  String get description {
    switch (this) {
      case TaskFilter.due:
        return 'Due tasks: need your attention now — act or complete.';
      case TaskFilter.inbox:
        return 'Inbox: captured tasks awaiting planning.';
      case TaskFilter.done:
        return 'Completed tasks — review or reopen as needed.';
      case TaskFilter.all:
        return 'Task library: active task intentions. Open a task to view, edit, pause, archive, or manage its plan.';
      case TaskFilter.paused:
        return 'Paused tasks: temporarily stopped and not scheduled.';
      case TaskFilter.history:
        return 'History: past completed tasks for inspection.';
      case TaskFilter.archive:
        return 'Archived tasks hidden from active views — restore or delete permanently.';
    }
  }

  String get apiFilter {
    switch (this) {
      case TaskFilter.done:
        return 'COMPLETED';
      case TaskFilter.archive:
        return 'ARCHIVED';
      case TaskFilter.due:
      case TaskFilter.inbox:
      case TaskFilter.all:
      case TaskFilter.paused:
      case TaskFilter.history:
        return 'ACTIVE';
    }
  }

  bool get isPrimary {
    switch (this) {
      case TaskFilter.due:
      case TaskFilter.inbox:
      case TaskFilter.done:
        return true;
      case TaskFilter.all:
      case TaskFilter.paused:
      case TaskFilter.history:
      case TaskFilter.archive:
        return false;
    }
  }

  bool get isMore => !isPrimary;

  bool get canCreate {
    switch (this) {
      case TaskFilter.due:
      case TaskFilter.inbox:
      case TaskFilter.all:
        return true;
      case TaskFilter.done:
      case TaskFilter.paused:
      case TaskFilter.history:
      case TaskFilter.archive:
        return false;
    }
  }

  bool get canClearDone => this == TaskFilter.done;
}

const taskPrimaryFilters = <TaskFilter>[
  TaskFilter.due,
  TaskFilter.inbox,
  TaskFilter.done,
];

const taskMoreFilters = <TaskFilter>[
  TaskFilter.all,
  TaskFilter.paused,
  TaskFilter.history,
  TaskFilter.archive,
];
