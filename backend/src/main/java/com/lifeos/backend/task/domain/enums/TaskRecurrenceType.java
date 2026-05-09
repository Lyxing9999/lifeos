package com.lifeos.backend.task.domain.enums;

/**
 * Defines how a TaskTemplate repeats.
 *
 * Important:
 * Recurrence belongs to TaskTemplate.
 * TaskInstance is the real spawned occurrence.
 */
public enum TaskRecurrenceType {

    /**
     * No recurrence.
     *
     * Used for one-time templates or manual task instances.
     */
    NONE,

    /**
     * Repeats every day.
     *
     * Example:
     * Study English every day.
     */
    DAILY,

    /**
     * Repeats weekly on the same day as recurrenceStartDate.
     *
     * Example:
     * recurrenceStartDate = Monday
     * -> repeats every Monday.
     */
    WEEKLY,

    /**
     * Repeats on selected weekdays.
     *
     * Example:
     * MONDAY,WEDNESDAY,FRIDAY
     */
    CUSTOM_WEEKLY,

    /**
     * Repeats monthly on the same day-of-month as recurrenceStartDate.
     *
     * Example:
     * recurrenceStartDate = 2026-05-08
     * -> repeats on the 8th of each month.
     */
    MONTHLY;

    public boolean isRecurring() {
        return this != NONE;
    }

    public boolean isWeeklyBased() {
        return this == WEEKLY || this == CUSTOM_WEEKLY;
    }

    public boolean requiresStartDate() {
        return this != NONE;
    }

    public boolean requiresDaysOfWeek() {
        return this == CUSTOM_WEEKLY;
    }

    public boolean usesStartDateDayOfWeek() {
        return this == WEEKLY;
    }

    public boolean usesStartDateDayOfMonth() {
        return this == MONTHLY;
    }
}