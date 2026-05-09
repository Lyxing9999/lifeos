package com.lifeos.backend.task.domain.valueobject;

import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
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
 * Value object for task recurrence.
 *
 * Belongs mainly to TaskTemplate.
 */
@Embeddable
@Getter
@Setter
public class RecurrenceRule {

    @Enumerated(EnumType.STRING)
    @Column(name = "recurrence_type", nullable = false, length = 40)
    private TaskRecurrenceType type = TaskRecurrenceType.NONE;

    @Column(name = "recurrence_start_date")
    private LocalDate startDate;

    @Column(name = "recurrence_end_date")
    private LocalDate endDate;

    /**
     * Used for CUSTOM_WEEKLY.
     *
     * Example:
     * MONDAY,WEDNESDAY,FRIDAY
     */
    @Column(name = "recurrence_days_of_week", length = 200)
    private String daysOfWeek;

    public RecurrenceRule() {
    }

    public RecurrenceRule(
            TaskRecurrenceType type,
            LocalDate startDate,
            LocalDate endDate,
            String daysOfWeek
    ) {
        this.type = type == null ? TaskRecurrenceType.NONE : type;
        this.startDate = startDate;
        this.endDate = endDate;
        this.daysOfWeek = normalizeDaysOfWeek(daysOfWeek);
    }

    public static RecurrenceRule none() {
        return new RecurrenceRule(
                TaskRecurrenceType.NONE,
                null,
                null,
                null
        );
    }

    public static RecurrenceRule daily(LocalDate startDate, LocalDate endDate) {
        return new RecurrenceRule(
                TaskRecurrenceType.DAILY,
                startDate,
                endDate,
                null
        );
    }

    public static RecurrenceRule weekly(LocalDate startDate, LocalDate endDate) {
        return new RecurrenceRule(
                TaskRecurrenceType.WEEKLY,
                startDate,
                endDate,
                null
        );
    }

    public static RecurrenceRule customWeekly(
            LocalDate startDate,
            LocalDate endDate,
            String daysOfWeek
    ) {
        return new RecurrenceRule(
                TaskRecurrenceType.CUSTOM_WEEKLY,
                startDate,
                endDate,
                daysOfWeek
        );
    }

    public static RecurrenceRule monthly(LocalDate startDate, LocalDate endDate) {
        return new RecurrenceRule(
                TaskRecurrenceType.MONTHLY,
                startDate,
                endDate,
                null
        );
    }

    public boolean isRecurring() {
        return type != null && type.isRecurring();
    }

    public boolean occursOn(LocalDate date) {
        if (date == null || !isRecurring()) {
            return false;
        }

        if (startDate == null) {
            return false;
        }

        if (date.isBefore(startDate)) {
            return false;
        }

        if (endDate != null && date.isAfter(endDate)) {
            return false;
        }

        return switch (type) {
            case DAILY -> true;
            case WEEKLY -> date.getDayOfWeek() == startDate.getDayOfWeek();
            case CUSTOM_WEEKLY -> allowedDays().contains(date.getDayOfWeek());
            case MONTHLY -> date.getDayOfMonth() == startDate.getDayOfMonth();
            case NONE -> false;
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
            this.type = TaskRecurrenceType.NONE;
        }

        if (type.requiresStartDate() && startDate == null) {
            throw new IllegalArgumentException("recurrenceStartDate is required");
        }

        if (endDate != null && startDate != null && endDate.isBefore(startDate)) {
            throw new IllegalArgumentException("recurrenceEndDate must be on or after recurrenceStartDate");
        }

        if (type.requiresDaysOfWeek() && (daysOfWeek == null || daysOfWeek.isBlank())) {
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