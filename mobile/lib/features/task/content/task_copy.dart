abstract final class TaskCopy {
  static const pageTitle = 'Tasks';
  static const pageSubtitle = 'Active work and what is due next';

  static const createTooltip = 'Create task';
  static const createAction = 'Create task';
  static const retry = 'Try again';

  static const loadErrorTitle = 'Could not load tasks';
  static const loadErrorFallback = 'Please try again.';

  static const emptyTitle = 'No active tasks';
  static const emptySubtitle = 'Add a task to make your next step clear.';

  static const loadingTaskTitle = 'Loading task';
  static const loadingTaskSubtitle = 'Preparing task details.';

  static const formNewTitle = 'New Task';
  static const formEditTitle = 'Edit Task';
  static const formNewSubtitle = 'Capture what needs to get done';
  static const formEditSubtitle = 'Update this task';
  static const formSubmitCreate = 'Create task';
  static const formSubmitEdit = 'Save changes';

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

  static const formProgressSubtitle = 'Track progress for this task';
  static const formProgressCurrent = 'Current progress';

  static const errorNotFound = 'Task not found';
  static const successCreated = 'Task created';
  static const successUpdated = 'Task updated';
  static const successCompleted = 'Task completed';
  static const successDeleted = 'Task deleted';

  static String progressHint(int percent) {
    if (percent >= 100) return 'Done and ready to complete.';
    if (percent == 0) return 'Not started yet.';
    return '$percent% complete.';
  }
}
