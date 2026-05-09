package com.lifeos.backend.task.domain.enums;

/**
 * Defines when unfinished work becomes MISSED.
 */
public enum MissedPolicy {

    /**
     * Never mark missed automatically.
     * Useful for flexible tasks.
     */
    NEVER_MISS,

    /**
     * Mark missed once exact due time passes.
     * Useful for meetings/classes/events.
     */
    MISS_AFTER_DUE_TIME,

    /**
     * Mark missed at the end of user's local day.
     */
    MISS_AT_END_OF_DAY,

    /**
     * Mark missed after a grace period.
     * Example: 30 minutes after due time.
     */
    MISS_AFTER_GRACE_PERIOD;

    public boolean canBecomeMissed() {
        return this != NEVER_MISS;
    }
}