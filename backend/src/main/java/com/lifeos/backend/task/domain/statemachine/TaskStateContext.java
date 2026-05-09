package com.lifeos.backend.task.domain.statemachine;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.UUID;

/**
 * Runtime context for a lifecycle transition.
 *
 * This keeps the state machine timezone-safe.
 * Do not use server-local date inside task lifecycle logic.
 */
public record TaskStateContext(
        UUID userId,
        ZoneId userZoneId,
        Instant now,
        LocalDate userToday,
        String actor
) {

    public static TaskStateContext of(
            UUID userId,
            ZoneId userZoneId,
            Instant now,
            String actor
    ) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }

        if (userZoneId == null) {
            throw new IllegalArgumentException("userZoneId is required");
        }

        Instant safeNow = now == null ? Instant.now() : now;
        String safeActor = actor == null || actor.isBlank() ? "USER" : actor.trim();

        return new TaskStateContext(
                userId,
                userZoneId,
                safeNow,
                safeNow.atZone(userZoneId).toLocalDate(),
                safeActor
        );
    }

    public static TaskStateContext system(
            UUID userId,
            ZoneId userZoneId
    ) {
        return of(userId, userZoneId, Instant.now(), "SYSTEM");
    }

    public static TaskStateContext engine(
            UUID userId,
            ZoneId userZoneId
    ) {
        return of(userId, userZoneId, Instant.now(), "ENGINE");
    }

    public static TaskStateContext user(
            UUID userId,
            ZoneId userZoneId
    ) {
        return of(userId, userZoneId, Instant.now(), "USER");
    }
}