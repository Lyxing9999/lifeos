package com.lifeos.backend.schedule.application.policy;

import com.lifeos.backend.schedule.domain.entity.ScheduleTemplate;
import com.lifeos.backend.schedule.domain.enums.ScheduleRecurrenceType;
import com.lifeos.backend.schedule.domain.service.ScheduleRecurrenceResolver;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.util.List;


/**
 * Policy for recurrence validation and occurrence matching.
 *
 * This wraps domain recurrence logic with decision objects
 * that application services/controllers can use.
 */
@Component
@RequiredArgsConstructor
public class ScheduleRecurrencePolicy {

    private final ScheduleRecurrenceResolver recurrenceResolver;

    public RecurrenceDecision canSpawnOn(
            ScheduleTemplate template,
            LocalDate date
    ) {
        RecurrenceValidation validation = validateTemplate(template);

        if (!validation.valid()) {
            return RecurrenceDecision.no(validation.reason());
        }

        if (date == null) {
            return RecurrenceDecision.no("date is required");
        }

        if (!template.canSpawnOccurrences()) {
            return RecurrenceDecision.no("Schedule template cannot spawn occurrences");
        }

        boolean occurs = recurrenceResolver.occursOn(template, date);

        if (!occurs) {
            return RecurrenceDecision.no("Schedule template does not occur on " + date);
        }

        return RecurrenceDecision.yes("Schedule template occurs on " + date);
    }

    public List<LocalDate> occurrenceDatesBetween(
            ScheduleTemplate template,
            LocalDate windowStart,
            LocalDate windowEnd
    ) {
        validateWindow(windowStart, windowEnd);

        RecurrenceValidation validation = validateTemplate(template);

        if (!validation.valid()) {
            return List.of();
        }

        return recurrenceResolver.occurrenceDatesBetween(
                template,
                windowStart,
                windowEnd
        );
    }

    public RecurrenceValidation validateTemplate(ScheduleTemplate template) {
        if (template == null) {
            return RecurrenceValidation.invalid("ScheduleTemplate is required");
        }

        if (template.getTitle() == null || template.getTitle().isBlank()) {
            return RecurrenceValidation.invalid("title is required");
        }

        if (template.getStartTime() == null || template.getEndTime() == null) {
            return RecurrenceValidation.invalid("startTime and endTime are required");
        }

        if (!template.getStartTime().isBefore(template.getEndTime())) {
            return RecurrenceValidation.invalid("startTime must be before endTime");
        }

        if (template.getRecurrenceType() == null) {
            template.setRecurrenceType(ScheduleRecurrenceType.NONE);
        }

        if (template.getRecurrenceStartDate() == null) {
            return RecurrenceValidation.invalid("recurrenceStartDate is required");
        }

        if (template.getRecurrenceEndDate() != null
                && template.getRecurrenceEndDate().isBefore(template.getRecurrenceStartDate())) {
            return RecurrenceValidation.invalid(
                    "recurrenceEndDate must be on or after recurrenceStartDate"
            );
        }

        if (template.getRecurrenceType() == ScheduleRecurrenceType.CUSTOM_WEEKLY
                && recurrenceResolver.allowedDays(template).isEmpty()) {
            return RecurrenceValidation.invalid(
                    "recurrenceDaysOfWeek is required for CUSTOM_WEEKLY"
            );
        }

        return RecurrenceValidation.ok();
    }

    public RecurrenceDecision canChangeRecurrence(
            ScheduleTemplate template,
            ScheduleRecurrenceType newType,
            LocalDate newStartDate,
            LocalDate newEndDate,
            String newDaysOfWeek
    ) {
        if (template == null) {
            return RecurrenceDecision.no("ScheduleTemplate is required");
        }

        ScheduleRecurrenceType type = newType == null
                ? template.getRecurrenceType()
                : newType;

        LocalDate startDate = newStartDate == null
                ? template.getRecurrenceStartDate()
                : newStartDate;

        LocalDate endDate = newEndDate == null
                ? template.getRecurrenceEndDate()
                : newEndDate;

        String daysOfWeek = newDaysOfWeek == null
                ? template.getRecurrenceDaysOfWeek()
                : newDaysOfWeek;

        if (type == null) {
            type = ScheduleRecurrenceType.NONE;
        }

        if (startDate == null) {
            return RecurrenceDecision.no("recurrenceStartDate is required");
        }

        if (endDate != null && endDate.isBefore(startDate)) {
            return RecurrenceDecision.no(
                    "recurrenceEndDate must be on or after recurrenceStartDate"
            );
        }

        if (type == ScheduleRecurrenceType.CUSTOM_WEEKLY
                && (daysOfWeek == null || daysOfWeek.isBlank())) {
            return RecurrenceDecision.no(
                    "recurrenceDaysOfWeek is required for CUSTOM_WEEKLY"
            );
        }

        return RecurrenceDecision.yes("Recurrence can be changed");
    }

    private void validateWindow(
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
    public record RecurrenceValidation(
            boolean valid,
            String reason
    ) {
        public static RecurrenceValidation ok() {
            return new RecurrenceValidation(true, null);
        }

        public static RecurrenceValidation invalid(String reason) {
            return new RecurrenceValidation(false, reason);
        }
    }


    public record RecurrenceDecision(
            boolean allowed,
            String reason
    ) {
        public static RecurrenceDecision yes(String reason) {
            return new RecurrenceDecision(true, reason);
        }

        public static RecurrenceDecision no(String reason) {
            return new RecurrenceDecision(false, reason);
        }
    }

}