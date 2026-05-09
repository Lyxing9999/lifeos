package com.lifeos.backend.schedule.domain.enums;

/**
 * Status of the schedule blueprint.
 *
 * ScheduleTemplate = recurring/future planned time rule.
 *
 * Example:
 * "Deep Work every weekday from 9 AM to 11 AM"
 */
public enum ScheduleTemplateStatus {

    /**
     * Template can generate future schedule occurrences.
     */
    ACTIVE,

    /**
     * Template is temporarily stopped.
     * No new occurrences should spawn while paused.
     */
    PAUSED,

    /**
     * Template is hidden from active management.
     * Historical occurrences remain.
     */
    ARCHIVED;

    public boolean canSpawnOccurrences() {
        return this == ACTIVE;
    }

    public boolean isVisibleInActiveManagement() {
        return this == ACTIVE || this == PAUSED;
    }

    public boolean isArchived() {
        return this == ARCHIVED;
    }
}