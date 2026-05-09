package com.lifeos.backend.schedule.domain.enums;

/**
 * Where a ScheduleOccurrence came from.
 */
public enum ScheduleSourceType {

    /**
     * User manually created this occurrence.
     */
    MANUAL,

    /**
     * Created from recurring ScheduleTemplate.
     */
    RECURRING_SPAWN,

    /**
     * Created by rescheduling another occurrence.
     */
    RESCHEDULED,

    /**
     * Created/imported from external calendar.
     *
     * Future use:
     * Google Calendar, Apple Calendar, school calendar, etc.
     */
    CALENDAR_IMPORT,

    /**
     * Created by AI/suggestion system later.
     */
    AI_SUGGESTED;

    public boolean isSystemGenerated() {
        return this == RECURRING_SPAWN
                || this == CALENDAR_IMPORT
                || this == AI_SUGGESTED;
    }

    public boolean isUserGenerated() {
        return this == MANUAL || this == RESCHEDULED;
    }
}