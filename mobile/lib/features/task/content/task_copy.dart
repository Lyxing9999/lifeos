abstract final class TaskCopy {
  static const pageTitle = 'Tasks';
  static const pageSubtitle = 'Capture, plan, complete, and review your work';

  static const createTooltip = 'Create task';
  static const createAction = 'Create task';
  static const retry = 'Try again';

  static const loadErrorTitle = 'Could not load tasks';
  static const loadErrorFallback = 'Please try again.';

  // Main task surfaces
  static const todayTitle = 'Today';
  static const todaySubtitle = 'Planned work that needs action today';

  static const doneTitle = 'Done today';
  static const doneSubtitle = 'Tasks completed for this day';

  static const allTodayTitle = 'All today';
  static const allTodaySubtitle = 'Active and completed work for this day';

  static const inboxTitle = 'Inbox';
  static const inboxSubtitle = 'Quick tasks waiting to be planned';

  static const historyTitle = 'History';
  static const historySubtitle = 'Completed work that stays in history';

  static const pausedTitle = 'Paused';
  static const pausedSubtitle = 'Stopped tasks you can resume later';

  static const archiveTitle = 'Archive';
  static const archiveSubtitle = 'Hidden tasks you can restore later';

  // Empty states
  static const emptyTodayTitle = 'No tasks for today';
  static const emptyTodaySubtitle =
      'Plan from Inbox or create a task with today as the due date.';

  static const emptyDoneTitle = 'Nothing completed today';
  static const emptyDoneSubtitle =
      'No completed tasks here. Cleared tasks still count in History.';

  static const emptyAllTitle = 'No tasks for this day';
  static const emptyAllSubtitle = 'No tasks yet.';

  static const emptyInboxTitle = 'No inbox tasks';
  static const emptyInboxSubtitle = 'Tasks without due dates appear here.';

  static const emptyHistoryTitle = 'No completed history for this day';
  static const emptyHistorySubtitle =
      'Completed tasks will appear here, even after clearing Done.';

  static const emptyPausedTitle = 'No paused tasks';
  static const emptyPausedSubtitle =
      'Paused tasks are hidden from Active until resumed.';

  static const emptyArchiveTitle = 'No archived tasks';
  static const emptyArchiveSubtitle =
      'Archived tasks will appear here for restore or permanent delete.';

  // Backward-compatible generic empty copy
  static const emptyTitle = emptyTodayTitle;
  static const emptySubtitle = emptyTodaySubtitle;

  // Loading
  static const loadingTaskTitle = 'Loading task';
  static const loadingTaskSubtitle = 'Preparing task details.';

  // Form
  static const formNewTitle = 'New Task';
  static const formEditTitle = 'Edit Task';
  static const formNewSubtitle = 'Capture now, plan later if needed';
  static const formEditSubtitle = 'Update task details';
  static const formSubmitCreate = 'Create task';
  static const formSubmitEdit = 'Save task';

  static const formSectionWhat = 'What';
  static const formSectionWhen = 'When';
  static const formSectionHow = 'How';
  static const formSectionProgress = 'Progress';
  static const formSectionRepeat = 'Repeat';
  static const formSectionTags = 'Tags';
  static const formSectionAdvanced = 'Advanced';

  static const formTitleLabel = 'Task title';
  static const formTitleHint = 'Review proposal, Go to gym, Pay rent';

  static const formCategoryLabel = 'Category';
  static const formCategoryMore = 'More';
  static const formCategoryCustomLabel = 'Custom category';
  static const formCategoryCustomHint = 'Type a category name';
  static const formCategoryDefault = 'Other';

  static const formAddNote = 'Add note (optional)';
  static const formHideNote = 'Hide note';
  static const formNoteLabel = 'Note';
  static const formNoteHint = 'Add details (optional)';

  static const formProgressSubtitle =
      'Track progress without changing where the task lives';
  static const formProgressCurrent = 'Current progress';

  // Action feedback
  static const errorNotFound = 'Task not found';
  static const successCreated = 'Task created';
  static const successUpdated = 'Task updated';
  static const successCompleted = 'Task completed';
  static const successCompletedFromInbox = 'Completed — removed from Inbox';
  static const successCompletedToDone = 'Completed — moved to Done';
  static const successReopened = 'Task reopened';
  static const successReopenedToToday = 'Reopened — moved to Today';
  static const successReopenedToInbox = 'Reopened — moved to Inbox';
  static const successDoneCleared = 'History and Timeline stay intact.';
  static const successPaused = 'Task paused';
  static const successResumed = 'Task resumed';
  static const successArchived = 'Task archived';
  static const successRestored = 'Task restored';
  static const successDeleted = 'Task deleted';
  static const successDeletedPermanently = 'Task deleted permanently';

  // Menus
  static const menuArchive = 'Archive task';
  static const menuRestore = 'Restore task';
  static const menuPause = 'Pause task';
  static const menuResume = 'Resume task';
  static const menuRemove = 'Remove task';
  static const menuDeletePermanently = 'Delete permanently';

  static const removeDialogTitle = 'Remove task';
  static const removeDialogArchive = 'Archive task';
  static const removeDialogRestore = 'Restore task';
  static const removeDialogDelete = 'Delete permanently';
  static const removeDialogCancel = 'Cancel';

  // Done list cleanup
  static const clearDoneAction = 'Clear Done';
  static const clearDoneTitle = 'Clear Done list?';
  static const clearDoneBody =
      'This hides completed tasks from this day’s Done list. Task history, Today, and Timeline stay intact.';
  static const clearDoneConfirm = 'Clear Done';

  // Schedule
  static const formSectionSchedule = 'Schedule link';
  static const formScheduleLabel = 'Linked schedule block';
  static const formScheduleNone = 'No linked schedule';
  static const formScheduleHint = 'Attach this task to a planned block';
  static const formScheduleEmpty = 'No active schedule blocks yet';
  static const formScheduleClear = 'Clear link';

  static String progressHint(int percent) {
    if (percent >= 100) {
      return '100% complete. Tap Complete when you are ready to close it.';
    }

    if (percent == 0) {
      return 'Not started yet.';
    }

    return '$percent% complete.';
  }
}
