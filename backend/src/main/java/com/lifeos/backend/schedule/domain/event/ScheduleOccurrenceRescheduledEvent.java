package com.lifeos.backend.schedule.domain.event;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Published when a ScheduleOccurrence is moved to another time/date.
 *
 * Source occurrence:
 * - becomes RESCHEDULED
 *
 * Target occurrence:
 * - usually becomes PLANNED
 */
public record ScheduleOccurrenceRescheduledEvent(
        UUID userId,

        UUID sourceScheduleOccurrenceId,
        UUID targetScheduleOccurrenceId,
        UUID scheduleTemplateId,

        String titleSnapshot,
        String categorySnapshot,
        String statusSnapshot,

        LocalDate originalOccurrenceDate,

        LocalDateTime fromStartDateTime,
        LocalDateTime fromEndDateTime,

        LocalDateTime toStartDateTime,
        LocalDateTime toEndDateTime,

        Instant rescheduledAt,
        String reason,
        String timezone
) {
    public String dedupeKey() {
        return "SCHEDULE_RESCHEDULED:"
                + sourceScheduleOccurrenceId
                + ":"
                + rescheduledAt;
    }
}