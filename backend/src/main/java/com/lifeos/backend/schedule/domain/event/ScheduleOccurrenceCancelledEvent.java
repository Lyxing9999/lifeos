package com.lifeos.backend.schedule.domain.event;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Published when a ScheduleOccurrence is cancelled.
 *
 * CANCELLED is stronger than SKIPPED.
 * Example:
 * - class cancelled
 * - meeting cancelled
 * - calendar block cancelled
 */
public record ScheduleOccurrenceCancelledEvent(
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

        Instant cancelledAt,
        String reason,
        String timezone
) {
    public String dedupeKey() {
        return "SCHEDULE_CANCELLED:" + scheduleOccurrenceId;
    }
}