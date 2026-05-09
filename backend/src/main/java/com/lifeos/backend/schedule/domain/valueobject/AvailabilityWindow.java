package com.lifeos.backend.schedule.domain.valueobject;

import lombok.Getter;

import java.time.Duration;
import java.time.LocalDateTime;

/**
 * Represents a free time window.
 *
 * Used later by:
 * - ScheduleAvailabilityQueryService
 * - Today suggestions
 * - AI planning
 */
@Getter
public class AvailabilityWindow {

    private final LocalDateTime startDateTime;
    private final LocalDateTime endDateTime;
    private final long durationMinutes;

    public AvailabilityWindow(
            LocalDateTime startDateTime,
            LocalDateTime endDateTime
    ) {
        if (startDateTime == null || endDateTime == null) {
            throw new IllegalArgumentException("startDateTime and endDateTime are required");
        }

        if (!startDateTime.isBefore(endDateTime)) {
            throw new IllegalArgumentException("startDateTime must be before endDateTime");
        }

        this.startDateTime = startDateTime;
        this.endDateTime = endDateTime;
        this.durationMinutes = Duration.between(startDateTime, endDateTime).toMinutes();
    }

    public boolean canFitMinutes(long requiredMinutes) {
        return requiredMinutes > 0 && durationMinutes >= requiredMinutes;
    }

    public boolean overlaps(LocalDateTime start, LocalDateTime end) {
        if (start == null || end == null) {
            return false;
        }

        return startDateTime.isBefore(end) && endDateTime.isAfter(start);
    }
}