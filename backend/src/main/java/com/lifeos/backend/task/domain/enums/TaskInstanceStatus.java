package com.lifeos.backend.task.domain.enums;

/**
 * Status of one real executable task occurrence.
 *
 * Instance = actual work item for a specific date/time.
 */
public enum TaskInstanceStatus {

    /**
     * Captured task with no planned date/time yet.
     */
    INBOX,

    /**
     * Planned for a future date/time.
     */
    SCHEDULED,

    /**
     * Planned for the user's current local day.
     */
    DUE_TODAY,

    /**
     * User has started working on it.
     */
    IN_PROGRESS,

    /**
     * Due window passed but the task is still actionable.
     */
    OVERDUE,

    /**
     * User completed this occurrence.
     */
    COMPLETED,

    /**
     * This occurrence was moved forward to another date.
     * Historical truth is preserved.
     */
    ROLLED_OVER,

    /**
     * The occurrence was not completed and is no longer valid.
     * Example: missed class, missed meeting, missed deadline window.
     */
    MISSED,

    /**
     * User intentionally skipped this occurrence.
     * This is different from MISSED.
     */
    SKIPPED,

    /**
     * Temporarily paused.
     * previousStatus should remember where it came from.
     */
    PAUSED,

    /**
     * Archived from active views.
     * Historical data remains.
     */
    ARCHIVED,

    /**
     * Cancelled intentionally.
     */
    CANCELLED;

    public boolean isFinalState() {
        return this == COMPLETED
                || this == ROLLED_OVER
                || this == MISSED
                || this == SKIPPED
                || this == ARCHIVED
                || this == CANCELLED;
    }

    public boolean isWorkable() {
        return this == INBOX
                || this == SCHEDULED
                || this == DUE_TODAY
                || this == IN_PROGRESS
                || this == OVERDUE;
    }

    public boolean canStart() {
        return this == INBOX
                || this == SCHEDULED
                || this == DUE_TODAY
                || this == OVERDUE;
    }

    public boolean canComplete() {
        return this == INBOX
                || this == SCHEDULED
                || this == DUE_TODAY
                || this == IN_PROGRESS
                || this == OVERDUE;
    }

    public boolean canReopen() {
        return this == COMPLETED
                || this == MISSED
                || this == SKIPPED
                || this == ROLLED_OVER;
    }

    public boolean canReschedule() {
        return this == INBOX
                || this == SCHEDULED
                || this == DUE_TODAY
                || this == IN_PROGRESS
                || this == OVERDUE;
    }

    public boolean canRollover() {
        return this == DUE_TODAY
                || this == IN_PROGRESS
                || this == OVERDUE;
    }

    public boolean canMarkMissed() {
        return this == DUE_TODAY
                || this == IN_PROGRESS
                || this == OVERDUE;
    }

    public boolean canSkip() {
        return this == SCHEDULED
                || this == DUE_TODAY
                || this == OVERDUE;
    }

    public boolean canPause() {
        return this == INBOX
                || this == SCHEDULED
                || this == DUE_TODAY
                || this == IN_PROGRESS
                || this == OVERDUE;
    }
}