package com.lifeos.backend.task.domain.enums;

/**
 * User/system action that changes a TaskInstance lifecycle state.
 */
public enum TaskTransitionType {

    /**
     * System creates an instance when user creates a task with planned date/time or a recurring task.
     */
    CREATE,

    /**
     * Create an instance from a template.
     * Usually triggered by TaskSpawnerEngine.
     */
    SPAWN,

    /**
     * User starts working.
     */
    START,

    /**
     * User completes an instance.
     */
    COMPLETE,

    /**
     * User reopens a completed/missed/skipped/rolled-over instance.
     */
    REOPEN,

    /**
     * Move unfinished work to another date.
     */
    ROLLOVER,

    /**
     * Mark as overdue when due window passed but still actionable.
     */
    MARK_OVERDUE,

    /**
     * Mark as missed when the task is no longer valid.
     */
    MARK_MISSED,

    /**
     * User changes the planned date/time.
     */
    RESCHEDULE,

    /**
     * User intentionally skips one occurrence.
     */
    SKIP_OCCURRENCE,

    /**
     * Pause an instance temporarily.
     */
    PAUSE,

    /**
     * Resume a paused instance.
     */
    RESUME,

    /**
     * Archive an instance.
     */
    ARCHIVE,

    /**
     * Restore an archived instance.
     */
    RESTORE,

    /**
     * Cancel intentionally.
     */
    CANCEL,

    /**
     * Hide from Done view, but keep in history/timeline/analytics.
     */
    CLEAR_FROM_DONE,

    /**
     * Restore back into Done view.
     */
    RESTORE_TO_DONE
}