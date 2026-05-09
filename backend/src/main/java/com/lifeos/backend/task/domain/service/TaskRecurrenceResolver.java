package com.lifeos.backend.task.domain.service;

import com.lifeos.backend.task.domain.entity.TaskTemplate;
import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
import org.springframework.stereotype.Component;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Component
public class TaskRecurrenceResolver {

    public boolean occursOn(TaskTemplate template, LocalDate date) {
        if (template == null || date == null) {
            return false;
        }

        TaskRecurrenceType type = template.getRecurrenceType();

        if (type == null || type == TaskRecurrenceType.NONE) {
            return false;
        }

        LocalDate startDate = template.getRecurrenceStartDate();

        if (startDate == null) {
            return false;
        }

        if (date.isBefore(startDate)) {
            return false;
        }

        LocalDate endDate = template.getRecurrenceEndDate();

        if (endDate != null && date.isAfter(endDate)) {
            return false;
        }

        return switch (type) {
            case DAILY -> true;
            case WEEKLY -> date.getDayOfWeek() == startDate.getDayOfWeek();
            case CUSTOM_WEEKLY -> allowedDays(template).contains(date.getDayOfWeek());
            case MONTHLY -> date.getDayOfMonth() == startDate.getDayOfMonth();
            case NONE -> false;
        };
    }

    public List<LocalDate> occurrenceDatesBetween(
            TaskTemplate template,
            LocalDate startDate,
            LocalDate endDate
    ) {
        if (startDate == null) {
            throw new IllegalArgumentException("startDate is required");
        }

        if (endDate == null) {
            throw new IllegalArgumentException("endDate is required");
        }

        if (endDate.isBefore(startDate)) {
            throw new IllegalArgumentException("endDate must be on or after startDate");
        }

        List<LocalDate> result = new ArrayList<>();

        for (LocalDate date = startDate; !date.isAfter(endDate); date = date.plusDays(1)) {
            if (occursOn(template, date)) {
                result.add(date);
            }
        }

        return result;
    }

    public LocalDate nextOccurrenceOnOrAfter(
            TaskTemplate template,
            LocalDate fromDate
    ) {
        if (template == null || fromDate == null || !template.isRecurring()) {
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
            TaskTemplate template,
            LocalDate afterDate
    ) {
        if (afterDate == null) {
            return null;
        }

        return nextOccurrenceOnOrAfter(template, afterDate.plusDays(1));
    }

    public LocalDate previousOccurrenceOnOrBefore(
            TaskTemplate template,
            LocalDate fromDate
    ) {
        if (template == null || fromDate == null || !template.isRecurring()) {
            return null;
        }

        LocalDate minSearchDate = fromDate.minusYears(2);

        for (LocalDate date = fromDate; !date.isBefore(minSearchDate); date = date.minusDays(1)) {
            if (occursOn(template, date)) {
                return date;
            }
        }

        return null;
    }

    public Set<DayOfWeek> allowedDays(TaskTemplate template) {
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

    public void validate(TaskTemplate template) {
        if (template == null) {
            throw new IllegalArgumentException("TaskTemplate is required");
        }

        TaskRecurrenceType type = template.getRecurrenceType();

        if (type == null || type == TaskRecurrenceType.NONE) {
            return;
        }

        if (template.getRecurrenceStartDate() == null) {
            throw new IllegalArgumentException("recurrenceStartDate is required");
        }

        if (template.getRecurrenceEndDate() != null
                && template.getRecurrenceEndDate().isBefore(template.getRecurrenceStartDate())) {
            throw new IllegalArgumentException("recurrenceEndDate must be on or after recurrenceStartDate");
        }

        if (type == TaskRecurrenceType.CUSTOM_WEEKLY && allowedDays(template).isEmpty()) {
            throw new IllegalArgumentException("recurrenceDaysOfWeek is required for CUSTOM_WEEKLY");
        }
    }
}