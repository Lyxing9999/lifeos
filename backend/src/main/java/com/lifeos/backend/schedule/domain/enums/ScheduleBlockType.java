package com.lifeos.backend.schedule.domain.enums;

/**
 * Type/category of a schedule block.
 *
 * This helps Today, Timeline, color UI, analytics, and future AI suggestions.
 */
public enum ScheduleBlockType {

    /**
     * Deep work / coding / focused execution.
     */
    DEEP_WORK,

    /**
     * Study or learning time.
     */
    STUDY,

    /**
     * School/class block.
     */
    CLASS,

    /**
     * Meeting, call, appointment.
     */
    MEETING,

    /**
     * Exercise, gym, sport.
     */
    EXERCISE,

    /**
     * Meal time.
     */
    MEAL,

    /**
     * Sleep/rest.
     */
    REST,

    /**
     * Travel/commute.
     */
    TRAVEL,

    /**
     * Personal routine.
     */
    ROUTINE,

    /**
     * Break / free time.
     */
    BREAK,

    /**
     * Work shift or job time.
     */
    WORK,

    /**
     * Flexible placeholder.
     */
    FLEXIBLE,

    /**
     * Unknown or uncategorized.
     */
    OTHER;

    public boolean isFocusBlock() {
        return this == DEEP_WORK
                || this == STUDY
                || this == WORK
                || this == CLASS;
    }

    public boolean isPersonalBlock() {
        return this == EXERCISE
                || this == MEAL
                || this == REST
                || this == ROUTINE
                || this == BREAK;
    }

    public boolean isFixedTimeBlock() {
        return this == CLASS
                || this == MEETING
                || this == WORK
                || this == TRAVEL;
    }

    public boolean isFlexibleBlock() {
        return this == FLEXIBLE || this == OTHER;
    }
}