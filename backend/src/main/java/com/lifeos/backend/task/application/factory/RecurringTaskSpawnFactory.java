package com.lifeos.backend.task.application.factory;

import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.entity.TaskOccurrenceException;
import com.lifeos.backend.task.domain.entity.TaskTemplate;
import com.lifeos.backend.task.domain.enums.TaskOccurrenceExceptionType;
import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Factory for recurring task spawning.
 *
 * This factory decides:
 * - which occurrence dates are valid
 * - which dates are skipped
 * - which dates are rescheduled
 * - what TaskInstance should be created
 *
 * This factory does NOT query database directly.
 * Pass existing occurrence dates and exceptions from TaskSpawnerService.
 */
@Component
@RequiredArgsConstructor
public class RecurringTaskSpawnFactory {

    private final TaskInstanceFactory taskInstanceFactory;

    /**
     * Build spawn plan for one template.
     *
     * The service should pass:
     * - existingOccurrenceDates from TaskInstanceRepository
     * - occurrenceExceptions from TaskOccurrenceExceptionRepository
     */
    public SpawnPlan buildSpawnPlan(
            TaskTemplate template,
            LocalDate windowStart,
            LocalDate windowEnd,
            LocalDate userToday,
            Set<LocalDate> existingOccurrenceDates,
            List<TaskOccurrenceException> occurrenceExceptions
    ) {
        validateWindow(windowStart, windowEnd);

        if (template == null || !template.isActiveTemplate()) {
            return SpawnPlan.empty();
        }

        if (!template.isRecurring()) {
            return SpawnPlan.empty();
        }

        Set<LocalDate> existingDates = existingOccurrenceDates == null
                ? Set.of()
                : existingOccurrenceDates;

        List<TaskOccurrenceException> exceptions = occurrenceExceptions == null
                ? List.of()
                : occurrenceExceptions;

        List<TaskInstance> instances = new ArrayList<>();
        List<LocalDate> skippedDates = new ArrayList<>();
        List<LocalDate> ignoredExistingDates = new ArrayList<>();

        for (LocalDate date = windowStart; !date.isAfter(windowEnd); date = date.plusDays(1)) {
            if (!occursOn(template, date)) {
                continue;
            }

            if (existingDates.contains(date)) {
                ignoredExistingDates.add(date);
                continue;
            }

            TaskOccurrenceException exception = findExceptionForDate(exceptions, date);

            if (exception != null && exception.getType() == TaskOccurrenceExceptionType.SKIPPED) {
                skippedDates.add(date);
                continue;
            }

            SpawnTarget target = resolveSpawnTarget(template, date, exception);

            TaskInstance instance = taskInstanceFactory.createFromTemplate(
                    template,
                    date,
                    target.scheduledDate(),
                    target.dueDateTime(),
                    userToday
            );

            instances.add(instance);
        }

        return new SpawnPlan(instances, skippedDates, ignoredExistingDates);
    }

    /**
     * Check if template occurs on date.
     */
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
            case CUSTOM_WEEKLY -> occursOnCustomWeekly(template, date);
            case MONTHLY -> date.getDayOfMonth() == startDate.getDayOfMonth();
            case NONE -> false;
        };
    }

    /**
     * Get all occurrence dates in a spawn window.
     */
    public List<LocalDate> getOccurrenceDates(
            TaskTemplate template,
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

    private SpawnTarget resolveSpawnTarget(
            TaskTemplate template,
            LocalDate occurrenceDate,
            TaskOccurrenceException exception
    ) {
        if (exception != null && exception.getType() == TaskOccurrenceExceptionType.RESCHEDULED) {
            LocalDate scheduledDate = exception.getRescheduledDate() == null
                    ? occurrenceDate
                    : exception.getRescheduledDate();

            LocalDateTime dueDateTime = exception.getRescheduledDateTime();

            if (dueDateTime == null && template.getDefaultDueTime() != null) {
                dueDateTime = scheduledDate.atTime(template.getDefaultDueTime());
            }

            return new SpawnTarget(scheduledDate, dueDateTime);
        }

        LocalDate scheduledDate = occurrenceDate;

        LocalDateTime dueDateTime = null;

        if (template.getDefaultDueTime() != null) {
            dueDateTime = scheduledDate.atTime(template.getDefaultDueTime());
        }

        return new SpawnTarget(scheduledDate, dueDateTime);
    }

    private TaskOccurrenceException findExceptionForDate(
            List<TaskOccurrenceException> exceptions,
            LocalDate date
    ) {
        return exceptions.stream()
                .filter(exception -> date.equals(exception.getOccurrenceDate()))
                .findFirst()
                .orElse(null);
    }

    private boolean occursOnCustomWeekly(TaskTemplate template, LocalDate date) {
        Set<DayOfWeek> allowedDays = parseDaysOfWeek(template.getRecurrenceDaysOfWeek());
        return allowedDays.contains(date.getDayOfWeek());
    }

    private Set<DayOfWeek> parseDaysOfWeek(String raw) {
        if (raw == null || raw.isBlank()) {
            return Set.of();
        }

        Set<DayOfWeek> days = new HashSet<>();

        Arrays.stream(raw.split(","))
                .map(String::trim)
                .filter(value -> !value.isBlank())
                .map(String::toUpperCase)
                .forEach(value -> days.add(DayOfWeek.valueOf(value)));

        return days;
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

    private record SpawnTarget(
            LocalDate scheduledDate,
            LocalDateTime dueDateTime
    ) {
    }

    public record SpawnPlan(
            List<TaskInstance> instancesToCreate,
            List<LocalDate> skippedDates,
            List<LocalDate> ignoredExistingDates
    ) {
        public static SpawnPlan empty() {
            return new SpawnPlan(List.of(), List.of(), List.of());
        }

        public boolean hasInstancesToCreate() {
            return instancesToCreate != null && !instancesToCreate.isEmpty();
        }
    }
}