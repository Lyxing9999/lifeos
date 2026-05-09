package com.lifeos.backend.schedule.domain.event;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Published when a ScheduleOccurrence is intentionally skipped.
 *
 * SKIPPED is softer than CANCELLED.
 * Example:
 * - skip gym today
 * - skip study block today
 */
public record ScheduleOccurrenceSkippedEvent(
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

        Instant skippedAt,
        String reason,
        String timezone
) {
    public String dedupeKey() {
        return "SCHEDULE_SKIPPED:" + scheduleOccurrenceId;
    }
}