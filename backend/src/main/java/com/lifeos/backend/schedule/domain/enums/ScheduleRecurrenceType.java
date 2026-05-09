package com.lifeos.backend.schedule.domain.enums;

/**
 * Defines how a ScheduleTemplate repeats.
 *
 * Schedule recurrence belongs to ScheduleTemplate.
 * ScheduleOccurrence is the real spawned time block.
 */
public enum ScheduleRecurrenceType {

    /**
     * Happens once on recurrenceStartDate.
     */
    NONE,

    /**
     * Repeats every day.
     */
    DAILY,

    /**
     * Repeats weekly on the same day as recurrenceStartDate.
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
     */
    MONTHLY;

    public boolean isRecurring() {
        return this != NONE;
    }

    public boolean isOneTime() {
        return this == NONE;
    }

    public boolean requiresStartDate() {
        return true;
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