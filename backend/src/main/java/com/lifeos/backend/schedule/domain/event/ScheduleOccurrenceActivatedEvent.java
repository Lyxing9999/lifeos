package com.lifeos.backend.schedule.domain.event;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Published when a ScheduleOccurrence becomes active.
 *
 * Usually this does NOT need a TimelineEntry because ACTIVE is temporary.
 * But keeping the event is useful for notification, websocket, or live Today updates later.
 */
public record ScheduleOccurrenceActivatedEvent(
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

        Instant activatedAt,
        String timezone
) {
    public String dedupeKey() {
        return "SCHEDULE_ACTIVE:" + scheduleOccurrenceId;
    }
}