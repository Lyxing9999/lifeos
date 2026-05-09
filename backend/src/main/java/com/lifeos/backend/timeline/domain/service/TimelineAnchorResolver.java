package com.lifeos.backend.timeline.domain.service;

import com.lifeos.backend.timeline.domain.entity.TimelineEntry;
import com.lifeos.backend.timeline.domain.enums.TimelineAnchorType;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.UUID;

/**
 * Resolves how a TimelineEntry appears on a selected user-local day.
 *
 * This is the core rule for:
 * - POINT entries like task completion / finance transaction
 * - SPAN entries like schedule blocks / stay sessions
 * - ALL_DAY entries like day summaries or special markers
 *
 * Important:
 * This service is pure domain logic.
 * It does not query database.
 * It does not mutate TimelineEntry.
 */
@Component
public class TimelineAnchorResolver {

    public TimelineAnchor resolve(
            TimelineEntry entry,
            LocalDate targetDate,
            ZoneId userZoneId
    ) {
        if (entry == null) {
            throw new IllegalArgumentException("TimelineEntry is required");
        }

        return resolve(
                entry.getId(),
                entry.getAnchorType(),
                entry.getStartAt(),
                entry.getEndAt(),
                targetDate,
                userZoneId
        );
    }

    public TimelineAnchor resolve(
            UUID entryId,
            TimelineAnchorType anchorType,
            Instant startAt,
            Instant endAt,
            LocalDate targetDate,
            ZoneId userZoneId
    ) {
        validateTarget(targetDate, userZoneId);

        TimelineAnchorType resolvedType = anchorType == null
                ? inferAnchorType(startAt, endAt)
                : anchorType;

        return switch (resolvedType) {
            case POINT -> resolvePoint(
                    entryId,
                    startAt,
                    targetDate,
                    userZoneId
            );

            case SPAN -> resolveSpan(
                    entryId,
                    startAt,
                    endAt,
                    targetDate,
                    userZoneId
            );

            case ALL_DAY -> resolveAllDay(
                    entryId,
                    startAt,
                    endAt,
                    targetDate,
                    userZoneId
            );
        };
    }

    /**
     * Query condition helper.
     *
     * Use this same rule in repository query:
     *
     * POINT:
     * startAt >= dayStart AND startAt < dayEnd
     *
     * SPAN:
     * startAt < dayEnd AND endAt > dayStart
     */
    public boolean appearsOnDate(
            TimelineAnchorType anchorType,
            Instant startAt,
            Instant endAt,
            LocalDate targetDate,
            ZoneId userZoneId
    ) {
        return resolve(
                null,
                anchorType,
                startAt,
                endAt,
                targetDate,
                userZoneId
        ).visibleOnDate();
    }

    public Instant dayStartAt(
            LocalDate targetDate,
            ZoneId userZoneId
    ) {
        validateTarget(targetDate, userZoneId);
        return targetDate.atStartOfDay(userZoneId).toInstant();
    }

    public Instant dayEndAt(
            LocalDate targetDate,
            ZoneId userZoneId
    ) {
        validateTarget(targetDate, userZoneId);
        return targetDate.plusDays(1).atStartOfDay(userZoneId).toInstant();
    }

    public TimelineAnchorType inferAnchorType(
            Instant startAt,
            Instant endAt
    ) {
        if (startAt != null && endAt != null && endAt.isAfter(startAt)) {
            return TimelineAnchorType.SPAN;
        }

        return TimelineAnchorType.POINT;
    }

    private TimelineAnchor resolvePoint(
            UUID entryId,
            Instant startAt,
            LocalDate targetDate,
            ZoneId userZoneId
    ) {
        if (startAt == null) {
            return TimelineAnchor.hidden(
                    entryId,
                    TimelineAnchorType.POINT,
                    targetDate,
                    dayStartAt(targetDate, userZoneId),
                    dayEndAt(targetDate, userZoneId),
                    "POINT entry requires startAt"
            );
        }

        Instant dayStart = dayStartAt(targetDate, userZoneId);
        Instant dayEnd = dayEndAt(targetDate, userZoneId);

        boolean visible = !startAt.isBefore(dayStart)
                && startAt.isBefore(dayEnd);

        if (!visible) {
            return TimelineAnchor.hidden(
                    entryId,
                    TimelineAnchorType.POINT,
                    targetDate,
                    dayStart,
                    dayEnd,
                    "POINT entry is outside selected date"
            );
        }

        LocalDateTime localStart = startAt.atZone(userZoneId).toLocalDateTime();

        return new TimelineAnchor(
                entryId,
                TimelineAnchorType.POINT,
                true,
                targetDate,
                dayStart,
                dayEnd,
                startAt,
                null,
                localStart,
                null,
                false,
                false,
                false,
                false,
                false,
                0,
                startAt,
                "POINT entry visible on selected date"
        );
    }

    private TimelineAnchor resolveSpan(
            UUID entryId,
            Instant startAt,
            Instant endAt,
            LocalDate targetDate,
            ZoneId userZoneId
    ) {
        if (startAt == null) {
            return TimelineAnchor.hidden(
                    entryId,
                    TimelineAnchorType.SPAN,
                    targetDate,
                    dayStartAt(targetDate, userZoneId),
                    dayEndAt(targetDate, userZoneId),
                    "SPAN entry requires startAt"
            );
        }

        Instant dayStart = dayStartAt(targetDate, userZoneId);
        Instant dayEnd = dayEndAt(targetDate, userZoneId);

        /**
         * Open-ended span support.
         *
         * Example:
         * stay session started but not closed yet.
         */
        Instant safeEndAt = endAt == null ? dayEnd : endAt;

        boolean visible = startAt.isBefore(dayEnd)
                && safeEndAt.isAfter(dayStart);

        if (!visible) {
            return TimelineAnchor.hidden(
                    entryId,
                    TimelineAnchorType.SPAN,
                    targetDate,
                    dayStart,
                    dayEnd,
                    "SPAN entry does not overlap selected date"
            );
        }

        Instant clippedStart = max(startAt, dayStart);
        Instant clippedEnd = min(safeEndAt, dayEnd);

        boolean startsBeforeDay = startAt.isBefore(dayStart);
        boolean endsAfterDay = safeEndAt.isAfter(dayEnd);

        boolean clippedStartFlag = !clippedStart.equals(startAt);
        boolean clippedEndFlag = !clippedEnd.equals(safeEndAt);

        long visibleMinutes = Math.max(
                0,
                Duration.between(clippedStart, clippedEnd).toMinutes()
        );

        LocalDateTime localStart = clippedStart.atZone(userZoneId).toLocalDateTime();
        LocalDateTime localEnd = clippedEnd.atZone(userZoneId).toLocalDateTime();

        boolean spansMultipleDays = !startAt.atZone(userZoneId).toLocalDate()
                .equals(safeEndAt.atZone(userZoneId).toLocalDate());

        return new TimelineAnchor(
                entryId,
                TimelineAnchorType.SPAN,
                true,
                targetDate,
                dayStart,
                dayEnd,
                clippedStart,
                clippedEnd,
                localStart,
                localEnd,
                clippedStartFlag,
                clippedEndFlag,
                startsBeforeDay,
                endsAfterDay,
                spansMultipleDays,
                visibleMinutes,
                clippedStart,
                "SPAN entry overlaps selected date"
        );
    }

    private TimelineAnchor resolveAllDay(
            UUID entryId,
            Instant startAt,
            Instant endAt,
            LocalDate targetDate,
            ZoneId userZoneId
    ) {
        Instant dayStart = dayStartAt(targetDate, userZoneId);
        Instant dayEnd = dayEndAt(targetDate, userZoneId);

        if (startAt == null) {
            return new TimelineAnchor(
                    entryId,
                    TimelineAnchorType.ALL_DAY,
                    true,
                    targetDate,
                    dayStart,
                    dayEnd,
                    dayStart,
                    dayEnd,
                    targetDate.atStartOfDay(),
                    targetDate.plusDays(1).atStartOfDay(),
                    false,
                    false,
                    false,
                    false,
                    false,
                    Duration.between(dayStart, dayEnd).toMinutes(),
                    dayStart,
                    "ALL_DAY entry visible by selected date"
            );
        }

        Instant safeEndAt = endAt == null
                ? startAt.atZone(userZoneId)
                .toLocalDate()
                .plusDays(1)
                .atStartOfDay(userZoneId)
                .toInstant()
                : endAt;

        boolean visible = startAt.isBefore(dayEnd)
                && safeEndAt.isAfter(dayStart);

        if (!visible) {
            return TimelineAnchor.hidden(
                    entryId,
                    TimelineAnchorType.ALL_DAY,
                    targetDate,
                    dayStart,
                    dayEnd,
                    "ALL_DAY entry does not overlap selected date"
            );
        }

        return new TimelineAnchor(
                entryId,
                TimelineAnchorType.ALL_DAY,
                true,
                targetDate,
                dayStart,
                dayEnd,
                dayStart,
                dayEnd,
                targetDate.atStartOfDay(),
                targetDate.plusDays(1).atStartOfDay(),
                false,
                false,
                startAt.isBefore(dayStart),
                safeEndAt.isAfter(dayEnd),
                true,
                Duration.between(dayStart, dayEnd).toMinutes(),
                dayStart,
                "ALL_DAY entry visible on selected date"
        );
    }

    private Instant max(Instant left, Instant right) {
        return left.isAfter(right) ? left : right;
    }

    private Instant min(Instant left, Instant right) {
        return left.isBefore(right) ? left : right;
    }

    private void validateTarget(
            LocalDate targetDate,
            ZoneId userZoneId
    ) {
        if (targetDate == null) {
            throw new IllegalArgumentException("targetDate is required");
        }

        if (userZoneId == null) {
            throw new IllegalArgumentException("userZoneId is required");
        }
    }

    public record TimelineAnchor(
            UUID entryId,
            TimelineAnchorType anchorType,

            boolean visibleOnDate,
            LocalDate targetDate,

            Instant dayStartAt,
            Instant dayEndAt,

            /**
             * Effective clipped range for this selected day.
             *
             * For SPAN:
             * Original: 18:00 -> next day 08:00
             * Selected day 1: effectiveStart = 18:00, effectiveEnd = 00:00
             * Selected day 2: effectiveStart = 00:00, effectiveEnd = 08:00
             */
            Instant effectiveStartAt,
            Instant effectiveEndAt,

            LocalDateTime effectiveStartLocal,
            LocalDateTime effectiveEndLocal,

            boolean clippedStart,
            boolean clippedEnd,

            boolean startsBeforeDay,
            boolean endsAfterDay,
            boolean spansMultipleDays,

            long visibleDurationMinutes,

            /**
             * Used for chronological sorting.
             */
            Instant sortAt,

            String reason
    ) {
        public static TimelineAnchor hidden(
                UUID entryId,
                TimelineAnchorType anchorType,
                LocalDate targetDate,
                Instant dayStartAt,
                Instant dayEndAt,
                String reason
        ) {
            return new TimelineAnchor(
                    entryId,
                    anchorType,
                    false,
                    targetDate,
                    dayStartAt,
                    dayEndAt,
                    null,
                    null,
                    null,
                    null,
                    false,
                    false,
                    false,
                    false,
                    false,
                    0,
                    null,
                    reason
            );
        }
    }
}