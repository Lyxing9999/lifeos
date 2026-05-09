package com.lifeos.backend.timeline.domain.enums;

/**
 * What kind of fact this timeline entry represents.
 *
 * TimelineEntryType is product meaning.
 * TimelineSourceType is source module.
 */
public enum TimelineEntryType {

    TASK_CREATED,
    TASK_STARTED,
    TASK_COMPLETED,
    TASK_REOPENED,
    TASK_MISSED,
    TASK_SKIPPED,
    TASK_RESCHEDULED,
    TASK_ROLLED_OVER,
    TASK_CANCELLED,

    SCHEDULE_PLANNED,
    SCHEDULE_ACTIVE,
    SCHEDULE_EXPIRED,
    SCHEDULE_CANCELLED,
    SCHEDULE_SKIPPED,
    SCHEDULE_RESCHEDULED,

    STAY_STARTED,
    STAY_ENDED,
    STAY_SESSION,

    LOCATION_SNAPSHOT,

    FINANCIAL_TRANSACTION,
    FINANCIAL_SUMMARY,

    DAILY_SUMMARY,
    SYSTEM_NOTE;

    public boolean isTaskEvent() {
        return name().startsWith("TASK_");
    }

    public boolean isScheduleEvent() {
        return name().startsWith("SCHEDULE_");
    }

    public boolean isStayEvent() {
        return name().startsWith("STAY_");
    }

    public boolean isFinancialEvent() {
        return name().startsWith("FINANCIAL_");
    }
}