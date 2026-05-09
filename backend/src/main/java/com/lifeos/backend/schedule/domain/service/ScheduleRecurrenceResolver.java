package com.lifeos.backend.schedule.domain.service;

import com.lifeos.backend.schedule.domain.entity.ScheduleTemplate;
import com.lifeos.backend.schedule.domain.enums.ScheduleRecurrenceType;
import org.springframework.stereotype.Component;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Component
public class ScheduleRecurrenceResolver {

    public boolean occursOn(ScheduleTemplate template, LocalDate date) {
        if (template == null || date == null) {
            return false;
        }

        if (!template.canSpawnOccurrences()) {
            return false;
        }

        if (template.getRecurrenceStartDate() == null) {
            return false;
        }

        if (date.isBefore(template.getRecurrenceStartDate())) {
            return false;
        }

        if (template.getRecurrenceEndDate() != null
                && date.isAfter(template.getRecurrenceEndDate())) {
            return false;
        }

        ScheduleRecurrenceType type = template.getRecurrenceType();

        if (type == null) {
            type = ScheduleRecurrenceType.NONE;
        }

        return switch (type) {
            case NONE -> date.equals(template.getRecurrenceStartDate());
            case DAILY -> true;
            case WEEKLY -> date.getDayOfWeek() == template.getRecurrenceStartDate().getDayOfWeek();
            case CUSTOM_WEEKLY -> allowedDays(template).contains(date.getDayOfWeek());
            case MONTHLY -> date.getDayOfMonth() == template.getRecurrenceStartDate().getDayOfMonth();
        };
    }

    public List<LocalDate> occurrenceDatesBetween(
            ScheduleTemplate template,
            LocalDate windowStart,
            LocalDate windowEnd
    ) {
        validateWindow(windowStart, windowEnd);

        List<LocalDate> dates = new ArrayList<>();

        for (LocalDate date = windowStart; !date.isAfter(windowEnd); date = date.plusDays(1)) {
            if (occursOn(template, date)) {
                dates.add(date);
            }
        }

        return dates;
    }

    public LocalDate nextOccurrenceOnOrAfter(
            ScheduleTemplate template,
            LocalDate fromDate
    ) {
        if (template == null || fromDate == null) {
            return null;
        }

        LocalDate maxSearchDate = fromDate.plusYears(2);

        for (LocalDate date = fromDate; !date.isAfter(maxSearchDate); date = date.plusDays(1)) {
            if (occursOn(template, date)) {
                return date;
            }
        }

        return null;
    }

    public LocalDate nextOccurrenceAfter(
            ScheduleTemplate template,
            LocalDate afterDate
    ) {
        if (afterDate == null) {
            return null;
        }

        return nextOccurrenceOnOrAfter(template, afterDate.plusDays(1));
    }

    public Set<DayOfWeek> allowedDays(ScheduleTemplate template) {
        if (template == null) {
            return Set.of();
        }

        String raw = template.getRecurrenceDaysOfWeek();

        if (raw == null || raw.isBlank()) {
            return Set.of();
        }

        return Arrays.stream(raw.split(","))
                .map(String::trim)
                .filter(value -> !value.isBlank())
                .map(String::toUpperCase)
                .map(DayOfWeek::valueOf)
                .collect(Collectors.toSet());
    }

    public void validate(ScheduleTemplate template) {
        if (template == null) {
            throw new IllegalArgumentException("ScheduleTemplate is required");
        }

        template.validateTimeWindow();

        if (template.getTitle() == null || template.getTitle().isBlank()) {
            throw new IllegalArgumentException("title is required");
        }

        if (template.getRecurrenceStartDate() == null) {
            throw new IllegalArgumentException("recurrenceStartDate is required");
        }

        if (template.getRecurrenceEndDate() != null
                && template.getRecurrenceEndDate().isBefore(template.getRecurrenceStartDate())) {
            throw new IllegalArgumentException("recurrenceEndDate must be on or after recurrenceStartDate");
        }

        if (template.getRecurrenceType() == ScheduleRecurrenceType.CUSTOM_WEEKLY
                && allowedDays(template).isEmpty()) {
            throw new IllegalArgumentException("recurrenceDaysOfWeek is required for CUSTOM_WEEKLY");
        }
    }

    private void validateWindow(LocalDate windowStart, LocalDate windowEnd) {
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
}