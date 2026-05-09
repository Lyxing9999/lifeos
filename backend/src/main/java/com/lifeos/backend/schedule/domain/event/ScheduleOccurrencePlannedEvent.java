package com.lifeos.backend.schedule.domain.event;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Published when a real ScheduleOccurrence is created/planned.
 *
 * This is usually a SPAN Timeline entry:
 * startDateTime -> endDateTime
 */
public record ScheduleOccurrencePlannedEvent(
        UUID userId,
        UUID scheduleOccurrenceId,
        UUID scheduleTemplateId,

        String titleSnapshot,
        String categorySnapshot,
        String statusSnapshot,

        LocalDate occurrenceDate,
        LocalDate scheduledDate,

        LocalDateTime startDateTime,
        LocalDateTime endDateTime,

        String timezone
) {
    public String dedupeKey() {
        return "SCHEDULE_PLANNED:" + scheduleOccurrenceId;
    }
}