package com.lifeos.backend.schedule.domain.enums;

/**
 * Status of one real planned time block.
 *
 * ScheduleOccurrence = actual planned time on a real date.
 *
 * Important:
 * Schedule occurrence is NOT a task.
 * It should not use COMPLETED / MISSED / ROLLED_OVER.
 */
public enum ScheduleOccurrenceStatus {

    /**
     * Planned for the future or current day.
     */
    PLANNED,

    /**
     * Current time is inside this schedule block.
     */
    ACTIVE,

    /**
     * Time block passed.
     *
     * This does not mean user failed.
     * It only means the planned time window ended.
     */
    EXPIRED,

    /**
     * User/system cancelled this occurrence.
     */
    CANCELLED,

    /**
     * User intentionally skipped this occurrence.
     */
    SKIPPED,

    /**
     * This occurrence was moved to another time/date.
     *
     * Usually the old occurrence becomes RESCHEDULED,
     * and the new occurrence becomes PLANNED.
     */
    RESCHEDULED;

    public boolean isOpen() {
        return this == PLANNED || this == ACTIVE;
    }

    public boolean isFinalState() {
        return this == EXPIRED
                || this == CANCELLED
                || this == SKIPPED
                || this == RESCHEDULED;
    }

    public boolean canCancel() {
        return this == PLANNED || this == ACTIVE;
    }

    public boolean canSkip() {
        return this == PLANNED;
    }

    public boolean canReschedule() {
        return this == PLANNED || this == ACTIVE;
    }

    public boolean canExpire() {
        return this == PLANNED || this == ACTIVE;
    }

    public boolean canActivate() {
        return this == PLANNED;
    }
}