package com.lifeos.backend.task.domain.valueobject;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;

/**
 * User-local due date/time.
 *
 * Floating means:
 * - stores local date/time and timezone
 * - converts to Instant only when needed
 *
 * Useful because LifeOS is day-based and user-local-date matters.
 */
@Embeddable
@Getter
@Setter
public class FloatingDueDateTime {

    @Column(name = "floating_due_date")
    private LocalDate localDate;

    @Column(name = "floating_due_time")
    private LocalTime localTime;

    @Column(name = "floating_timezone", length = 80)
    private String timezone;

    public FloatingDueDateTime() {
    }

    public FloatingDueDateTime(
            LocalDate localDate,
            LocalTime localTime,
            String timezone
    ) {
        this.localDate = localDate;
        this.localTime = localTime;
        this.timezone = normalizeTimezone(timezone);
    }

    public static FloatingDueDateTime dateOnly(
            LocalDate localDate,
            String timezone
    ) {
        return new FloatingDueDateTime(localDate, null, timezone);
    }

    public static FloatingDueDateTime exact(
            LocalDate localDate,
            LocalTime localTime,
            String timezone
    ) {
        return new FloatingDueDateTime(localDate, localTime, timezone);
    }

    public static FloatingDueDateTime fromLocalDateTime(
            LocalDateTime localDateTime,
            String timezone
    ) {
        if (localDateTime == null) {
            return null;
        }

        return new FloatingDueDateTime(
                localDateTime.toLocalDate(),
                localDateTime.toLocalTime(),
                timezone
        );
    }

    public boolean isEmpty() {
        return localDate == null && localTime == null;
    }

    public boolean hasDate() {
        return localDate != null;
    }

    public boolean hasExactTime() {
        return localDate != null && localTime != null;
    }

    public LocalDateTime toLocalDateTimeOrStartOfDay() {
        if (localDate == null) {
            return null;
        }

        return localDate.atTime(localTime == null ? LocalTime.MIN : localTime);
    }

    public Instant toInstant() {
        LocalDateTime localDateTime = toLocalDateTimeOrStartOfDay();

        if (localDateTime == null) {
            return null;
        }

        return localDateTime.atZone(resolveZoneId()).toInstant();
    }

    public ZoneId resolveZoneId() {
        if (timezone == null || timezone.isBlank()) {
            throw new IllegalStateException("timezone is required");
        }

        return ZoneId.of(timezone);
    }

    public boolean isBefore(FloatingDueDateTime other) {
        if (other == null) {
            return false;
        }

        Instant left = this.toInstant();
        Instant right = other.toInstant();

        return left != null && right != null && left.isBefore(right);
    }

    public void validate() {
        if (localTime != null && localDate == null) {
            throw new IllegalArgumentException("localDate is required when localTime is set");
        }

        if (timezone != null && !timezone.isBlank()) {
            ZoneId.of(timezone);
        }
    }

    private String normalizeTimezone(String raw) {
        if (raw == null || raw.isBlank()) {
            return null;
        }

        return raw.trim();
    }
}