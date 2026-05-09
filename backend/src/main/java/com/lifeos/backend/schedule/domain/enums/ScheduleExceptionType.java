package com.lifeos.backend.schedule.domain.enums;

/**
 * One-occurrence exception for a ScheduleTemplate.
 *
 * Example:
 * Template: Deep Work every weekday 9 AM - 11 AM
 * Exception: skip Friday only
 * Exception: move Monday block to 2 PM - 4 PM
 */
public enum ScheduleExceptionType {

    /**
     * Do not spawn this occurrence.
     */
    SKIPPED,

    /**
     * Move this occurrence to another date/time.
     */
    RESCHEDULED,

    /**
     * Cancel this occurrence.
     *
     * Difference:
     * - SKIPPED = intentionally not doing this occurrence, usually casual
     * - CANCELLED = stronger explicit cancellation, useful for class/meeting/block cancellation
     */
    CANCELLED;

    public boolean preventsOriginalSpawn() {
        return this == SKIPPED
                || this == RESCHEDULED
                || this == CANCELLED;
    }
}