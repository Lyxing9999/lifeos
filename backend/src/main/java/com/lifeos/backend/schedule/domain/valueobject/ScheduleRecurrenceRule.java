package com.lifeos.backend.schedule.domain.valueobject;

import com.lifeos.backend.schedule.domain.enums.ScheduleRecurrenceType;
import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.Getter;
import lombok.Setter;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Value object for schedule recurrence.
 *
 * This is useful later if you want to embed recurrence into ScheduleTemplate.
 * For now, your entity already has raw recurrence fields, so this object
 * can be used by services/policies without forcing migration immediately.
 */
@Embeddable
@Getter
@Setter
public class ScheduleRecurrenceRule {

    @Enumerated(EnumType.STRING)
    @Column(name = "schedule_recurrence_type", nullable = false, length = 50)
    private ScheduleRecurrenceType type = ScheduleRecurrenceType.NONE;

    @Column(name = "schedule_recurrence_start_date")
    private LocalDate startDate;

    @Column(name = "schedule_recurrence_end_date")
    private LocalDate endDate;

    @Column(name = "schedule_recurrence_days_of_week", length = 120)
    private String daysOfWeek;

    public ScheduleRecurrenceRule() {
    }

    public ScheduleRecurrenceRule(
            ScheduleRecurrenceType type,
            LocalDate startDate,
            LocalDate endDate,
            String daysOfWeek
    ) {
        this.type = type == null ? ScheduleRecurrenceType.NONE : type;
        this.startDate = startDate;
        this.endDate = endDate;
        this.daysOfWeek = normalizeDaysOfWeek(daysOfWeek);
    }

    public static ScheduleRecurrenceRule once(LocalDate date) {
        return new ScheduleRecurrenceRule(
                ScheduleRecurrenceType.NONE,
                date,
                null,
                null
        );
    }

    public static ScheduleRecurrenceRule daily(
            LocalDate startDate,
            LocalDate endDate
    ) {
        return new ScheduleRecurrenceRule(
                ScheduleRecurrenceType.DAILY,
                startDate,
                endDate,
                null
        );
    }

    public static ScheduleRecurrenceRule weekly(
            LocalDate startDate,
            LocalDate endDate
    ) {
        return new ScheduleRecurrenceRule(
                ScheduleRecurrenceType.WEEKLY,
                startDate,
                endDate,
                null
        );
    }

    public static ScheduleRecurrenceRule customWeekly(
            LocalDate startDate,
            LocalDate endDate,
            String daysOfWeek
    ) {
        return new ScheduleRecurrenceRule(
                ScheduleRecurrenceType.CUSTOM_WEEKLY,
                startDate,
                endDate,
                daysOfWeek
        );
    }

    public static ScheduleRecurrenceRule monthly(
            LocalDate startDate,
            LocalDate endDate
    ) {
        return new ScheduleRecurrenceRule(
                ScheduleRecurrenceType.MONTHLY,
                startDate,
                endDate,
                null
        );
    }

    public boolean occursOn(LocalDate date) {
        if (date == null || type == null || startDate == null) {
            return false;
        }

        if (date.isBefore(startDate)) {
            return false;
        }

        if (endDate != null && date.isAfter(endDate)) {
            return false;
        }

        return switch (type) {
            case NONE -> date.equals(startDate);
            case DAILY -> true;
            case WEEKLY -> date.getDayOfWeek() == startDate.getDayOfWeek();
            case CUSTOM_WEEKLY -> allowedDays().contains(date.getDayOfWeek());
            case MONTHLY -> date.getDayOfMonth() == startDate.getDayOfMonth();
        };
    }

    public Set<DayOfWeek> allowedDays() {
        if (daysOfWeek == null || daysOfWeek.isBlank()) {
            return Set.of();
        }

        return Arrays.stream(daysOfWeek.split(","))
                .map(String::trim)
                .filter(value -> !value.isBlank())
                .map(String::toUpperCase)
                .map(DayOfWeek::valueOf)
                .collect(Collectors.toSet());
    }

    public void validate() {
        if (type == null) {
            type = ScheduleRecurrenceType.NONE;
        }

        if (startDate == null) {
            throw new IllegalArgumentException("recurrenceStartDate is required");
        }

        if (endDate != null && endDate.isBefore(startDate)) {
            throw new IllegalArgumentException("recurrenceEndDate must be on or after recurrenceStartDate");
        }

        if (type.requiresDaysOfWeek()
                && (daysOfWeek == null || daysOfWeek.isBlank())) {
            throw new IllegalArgumentException("recurrenceDaysOfWeek is required for CUSTOM_WEEKLY");
        }
    }

    private String normalizeDaysOfWeek(String raw) {
        if (raw == null || raw.isBlank()) {
            return null;
        }

        return Arrays.stream(raw.split(","))
                .map(String::trim)
                .filter(value -> !value.isBlank())
                .map(String::toUpperCase)
                .collect(Collectors.joining(","));
    }
}