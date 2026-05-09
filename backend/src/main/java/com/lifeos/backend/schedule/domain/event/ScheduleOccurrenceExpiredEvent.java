package com.lifeos.backend.schedule.domain.event;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Published when a ScheduleOccurrence time window ends.
 *
 * Important:
 * EXPIRED does not mean user failed.
 * It only means the planned time block ended.
 */
public record ScheduleOccurrenceExpiredEvent(
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

        Instant expiredAt,
        String timezone
) {
    public String dedupeKey() {
        return "SCHEDULE_EXPIRED:" + scheduleOccurrenceId;
    }
}