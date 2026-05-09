package com.lifeos.backend.task.application.policy;

import com.lifeos.backend.task.domain.entity.TaskTemplate;
import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
import org.springframework.stereotype.Component;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.Set;
import java.util.stream.Collectors;

@Component
public class RecurrencePolicyResolver {

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

    public Set<DayOfWeek> allowedDays(TaskTemplate template) {
        if (template == null || template.getRecurrenceDaysOfWeek() == null) {
            return Set.of();
        }

        String raw = template.getRecurrenceDaysOfWeek();

        if (raw.isBlank()) {
            return Set.of();
        }

        return Arrays.stream(raw.split(","))
                .map(String::trim)
                .filter(value -> !value.isBlank())
                .map(String::toUpperCase)
                .map(DayOfWeek::valueOf)
                .collect(Collectors.toSet());
    }

    public RecurrenceValidationResult validate(TaskTemplate template) {
        if (template == null) {
            return RecurrenceValidationResult.invalid("TaskTemplate is required");
        }

        TaskRecurrenceType type = template.getRecurrenceType();

        if (type == null || type == TaskRecurrenceType.NONE) {
            return RecurrenceValidationResult.ok();
        }

        if (template.getRecurrenceStartDate() == null) {
            return RecurrenceValidationResult.invalid("recurrenceStartDate is required");
        }

        if (template.getRecurrenceEndDate() != null
                && template.getRecurrenceEndDate().isBefore(template.getRecurrenceStartDate())) {
            return RecurrenceValidationResult.invalid(
                    "recurrenceEndDate must be on or after recurrenceStartDate"
            );
        }

        if (type == TaskRecurrenceType.CUSTOM_WEEKLY && allowedDays(template).isEmpty()) {
            return RecurrenceValidationResult.invalid(
                    "recurrenceDaysOfWeek is required for CUSTOM_WEEKLY"
            );
        }

        return RecurrenceValidationResult.ok();
    }

    public record RecurrenceValidationResult(
            boolean valid,
            String reason
    ) {
        public static RecurrenceValidationResult ok() {
            return new RecurrenceValidationResult(true, null);
        }

        public static RecurrenceValidationResult invalid(String reason) {
            return new RecurrenceValidationResult(false, reason);
        }
    }
}