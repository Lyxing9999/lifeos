package com.lifeos.backend.task.domain.enums;

/**
 * Defines what kind of reminder a task uses.
 *
 * ReminderType describes intent.
 * Notification channel/delivery belongs to notification domain later.
 */
public enum ReminderType {

    /**
     * No reminder.
     */
    NONE,

    /**
     * Reminder at an exact date-time.
     *
     * Example:
     * remind at 2026-05-08 08:30
     */
    EXACT_TIME,

    /**
     * Reminder before due time.
     *
     * Example:
     * 10 minutes before task dueDateTime.
     */
    BEFORE_DUE_TIME,

    /**
     * Reminder at the start of the user's local day.
     *
     * Example:
     * morning reminder for today's tasks.
     */
    START_OF_DAY,

    /**
     * Reminder near the end of the user's local day.
     *
     * Example:
     * evening reminder for unfinished tasks.
     */
    END_OF_DAY,

    /**
     * Reminder when the user enters or leaves a place.
     *
     * Future use for LifeOS place intelligence.
     */
    LOCATION_BASED,

    /**
     * Reminder based on schedule block.
     *
     * Example:
     * task linked to study block starts at 7 PM.
     */
    SCHEDULE_BASED,

    /**
     * Smart reminder selected by LifeOS.
     *
     * Future AI/prediction reminder.
     */
    SMART;

    public boolean isTimeBased() {
        return this == EXACT_TIME
                || this == BEFORE_DUE_TIME
                || this == START_OF_DAY
                || this == END_OF_DAY
                || this == SCHEDULE_BASED;
    }

    public boolean isContextBased() {
        return this == LOCATION_BASED
                || this == SMART;
    }

    public boolean isEnabled() {
        return this != NONE;
    }
}