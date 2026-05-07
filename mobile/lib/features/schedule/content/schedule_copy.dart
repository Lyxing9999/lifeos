abstract final class ScheduleCopy {
  static const pageTitle = 'Schedule';
  static const pageSubtitle = 'Planned blocks resolved for this day';
  static const detailTitle = 'Planned block details';

  static const createBlock = 'Create planned block';

  static const loadErrorTitle = 'Could not load planned blocks';
  static const loadErrorFallback = 'Please try again.';
  static const retry = 'Try again';
  static const emptyTitle = 'No planned blocks for this day';
  static const emptySubtitle = 'Add a planned block to shape the day.';

  static const sparseTitle = 'Lightly planned day';
  static const sparseMessage =
      'Add one more planned block to make your day clearer.';

  static const summaryPlannedTime = 'Planned time';
  static const summaryPlannedTimeHelper = 'Total for this day';
  static const summaryFirstBlock = 'First block';
  static const summaryFirstBlockHelper = 'Day starts';

  static const formNewTitle = 'New Schedule';
  static const formEditTitle = 'Edit Schedule';
  static const formNewSubtitle = 'Block time for what matters';
  static const formEditSubtitle = 'Update this planned block';
  static const formSubmitCreate = 'Create planned block';
  static const formSubmitEdit = 'Save changes';
  static const formSectionCore = 'Core';
  static const formSectionTimeBlock = 'Time block';
  static const formSectionRecurrence = 'Recurrence';
  static const formTitleHint = 'Morning work, Deep work, Gym, Study block';
  static const formDescriptionHint = 'Description (optional)';
  static const formStartTime = 'Start time';
  static const formEndTime = 'End time';
  static const formDurationPrefix = 'Duration';
  static const formRecurrenceDate = 'Date';
  static const formRecurrenceStartDate = 'Recurrence start date';
  static const formRecurrenceEndDate = 'Recurrence end date';
  static const noEndDate = 'No end date';
  static const formRecurrenceOnceHelper = 'Occurs once on the selected date.';
  static const formRecurrenceDailyHelper = 'Repeats every day.';
  static const formRecurrenceCustomWeeklyHelper =
      'Select weekdays for this recurring block.';
  static const formRecurrenceMonthlyHelper =
      'Repeats monthly on this calendar date.';
  static const formRecurrenceDaysHelper = 'Select at least one weekday.';

  static const errorTimeRange = 'End time must be after start time';
  static const errorRecurrenceDays =
      'Choose at least one day for Custom weekly';
  static const errorRecurrenceDateRange =
      'End date must be on or after start date';

  static const successCreated = 'Planned block created';
  static const successUpdated = 'Planned block updated';
  static const successDeactivated = 'Planned block deactivated';
  static const successActivated = 'Planned block activated';
  static const successDeleted = 'Planned block deleted';
  static const errorNotFound = 'Planned block not found';

  static const deactivateTooltip = 'Deactivate planned block';
  static const activateTooltip = 'Activate planned block';
  static const deactivateDialogTitle = 'Deactivate planned block?';
  static const deactivateDialogAction = 'Deactivate';
  static const activateDialogAction = 'Activate';
  static const removeDialogTitle = 'Remove schedule';
  static const removeDialogDeactivate = 'Deactivate schedule';
  static const removeDialogActivate = 'Activate schedule';
  static const removeDialogDelete = 'Delete permanently';
  static const deleteTooltip = 'Delete planned block';
  static const deleteDialogTitle = 'Delete planned block?';
  static const deleteDialogAction = 'Delete';
  static const cancelAction = 'Cancel';

  static const detailSectionCore = 'Core';
  static const detailSectionRecurrenceWindow = 'Recurrence window';
  static const detailSectionTime = 'Time';
  static const detailSectionRecurrence = 'Recurrence';
  static const detailType = 'Type';
  static const detailDescription = 'Description';
  static const detailNoDescription = 'No description';
  static const detailStatus = 'Status';
  static const detailStatusActive = 'Active';
  static const detailStatusInactive = 'Inactive';
  static const detailRecurrenceStartDate = 'Recurrence start date';
  static const detailRecurrenceEndDate = 'Recurrence end date';
  static const detailStartTime = 'Start';
  static const detailEndTime = 'End';
  static const detailRecurrenceType = 'Recurrence type';
  static const detailRecurrenceDays = 'Recurrence days of week';
  static const detailNone = 'None';

  static const filterAll = 'All';
  static const filterWork = 'Work';
  static const filterStudy = 'Study';
  static const filterPersonal = 'Personal';

  static String plannedBlocksCount(int count) {
    final noun = count == 1 ? 'planned block' : 'planned blocks';
    return '$count $noun resolved';
  }

  static String blockCountHelper(int count) {
    final noun = count == 1 ? 'block' : 'blocks';
    return '$count $noun';
  }

  static String formRecurrenceWeeklyHelper(String weekdayLabel) {
    return 'Repeats every $weekdayLabel.';
  }

  static String deactivateDialogBody(String title) {
    return '"$title" will stop appearing in your day.';
  }

  static String deleteDialogBody(String title) {
    return '"$title" will be removed permanently.';
  }
}
