package com.lifeos.backend.task.domain.enums;

/**
 * Defines how an unfinished task behaves after its planned time/date passes.
 *
 * Overdue means:
 * - the task is late
 * - but it may still be actionable
 *
 * This is different from MISSED.
 */
public enum OverduePolicy {

    /**
     * Never mark overdue automatically.
     *
     * Useful for flexible tasks where lateness does not matter.
     */
    NEVER_OVERDUE,

    /**
     * Mark overdue after the planned date passes.
     *
     * Example:
     * dueDate = 2026-05-08
     * on 2026-05-09 -> OVERDUE
     */
    OVERDUE_AFTER_DATE,

    /**
     * Mark overdue after exact dueDateTime passes.
     *
     * Example:
     * dueDateTime = 2026-05-08 09:00
     * at 09:01 -> OVERDUE
     */
    OVERDUE_AFTER_TIME,

    /**
     * Mark overdue at the end of the user's local day.
     *
     * Example:
     * due today
     * after 23:59 user-local time -> OVERDUE
     */
    OVERDUE_AT_END_OF_DAY,

    /**
     * Mark overdue after a grace period.
     *
     * Example:
     * due at 09:00
     * grace 30 minutes
     * at 09:30+ -> OVERDUE
     */
    OVERDUE_AFTER_GRACE_PERIOD;

    public boolean canBecomeOverdue() {
        return this != NEVER_OVERDUE;
    }

    public boolean requiresExactDueTime() {
        return this == OVERDUE_AFTER_TIME
                || this == OVERDUE_AFTER_GRACE_PERIOD;
    }

    public boolean isDateBased() {
        return this == OVERDUE_AFTER_DATE
                || this == OVERDUE_AT_END_OF_DAY;
    }
}