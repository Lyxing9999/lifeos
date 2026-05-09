package com.lifeos.backend.engine.recurrence;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

/**
 * Defines how far the system should pre-spawn recurring occurrences.
 *
 * Example:
 * today - 1 day -> today + 7 days
 *
 * This is useful because the mobile app needs:
 * - today tasks
 * - upcoming tasks
 * - timeline preview
 */
@Component
public class SpawnWindowPolicy {

    @Value("${lifeos.engine.spawn-window.past-days:1}")
    private int pastDays;

    @Value("${lifeos.engine.spawn-window.future-days:7}")
    private int futureDays;

    public SpawnWindow defaultWindow(LocalDate userToday) {
        if (userToday == null) {
            throw new IllegalArgumentException("userToday is required");
        }

        int safePastDays = Math.max(pastDays, 0);
        int safeFutureDays = Math.max(futureDays, 0);

        return new SpawnWindow(
                userToday.minusDays(safePastDays),
                userToday.plusDays(safeFutureDays)
        );
    }

    public SpawnWindow customWindow(
            LocalDate windowStart,
            LocalDate windowEnd
    ) {
        validateWindow(windowStart, windowEnd);
        return new SpawnWindow(windowStart, windowEnd);
    }

    public void validateWindow(
            LocalDate windowStart,
            LocalDate windowEnd
    ) {
        if (windowStart == null) {
            throw new IllegalArgumentException("windowStart is required");
        }

        if (windowEnd == null) {
            throw new IllegalArgumentException("windowEnd is required");
        }

        if (windowEnd.isBefore(windowStart)) {
            throw new IllegalArgumentException("windowEnd must be on or after windowStart");
        }
    }

    public record SpawnWindow(
            LocalDate startDate,
            LocalDate endDate
    ) {
    }
}