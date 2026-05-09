package com.lifeos.backend.task.domain.service;

import com.lifeos.backend.task.domain.entity.TaskOccurrenceException;
import com.lifeos.backend.task.domain.entity.TaskTemplate;
import com.lifeos.backend.task.domain.enums.TaskOccurrenceExceptionType;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;

@Component
@RequiredArgsConstructor
public class TaskSpawnPlanner {

    private final TaskRecurrenceResolver recurrenceResolver;

    public SpawnPlan plan(
            TaskTemplate template,
            LocalDate windowStart,
            LocalDate windowEnd,
            Set<LocalDate> existingOccurrenceDates,
            List<TaskOccurrenceException> exceptions
    ) {
        validateWindow(windowStart, windowEnd);

        if (template == null || !template.isActiveTemplate() || !template.isRecurring()) {
            return SpawnPlan.empty();
        }

        Set<LocalDate> existing = existingOccurrenceDates == null
                ? Set.of()
                : existingOccurrenceDates;

        List<TaskOccurrenceException> safeExceptions = exceptions == null
                ? List.of()
                : exceptions;

        List<SpawnCandidate> candidates = recurrenceResolver
                .occurrenceDatesBetween(template, windowStart, windowEnd)
                .stream()
                .map(date -> toCandidate(template, date, existing, safeExceptions))
                .toList();

        return new SpawnPlan(candidates);
    }

    private SpawnCandidate toCandidate(
            TaskTemplate template,
            LocalDate occurrenceDate,
            Set<LocalDate> existingOccurrenceDates,
            List<TaskOccurrenceException> exceptions
    ) {
        if (existingOccurrenceDates.contains(occurrenceDate)) {
            return SpawnCandidate.existing(occurrenceDate);
        }

        TaskOccurrenceException exception = findException(exceptions, occurrenceDate);

        if (exception != null && exception.getType() == TaskOccurrenceExceptionType.SKIPPED) {
            return SpawnCandidate.skipped(
                    occurrenceDate,
                    exception.getReason()
            );
        }

        if (exception != null && exception.getType() == TaskOccurrenceExceptionType.RESCHEDULED) {
            LocalDate targetDate = exception.getRescheduledDate() == null
                    ? occurrenceDate
                    : exception.getRescheduledDate();

            LocalDateTime targetDateTime = exception.getRescheduledDateTime();

            if (targetDateTime == null && template.getDefaultDueTime() != null) {
                targetDateTime = targetDate.atTime(template.getDefaultDueTime());
            }

            return SpawnCandidate.toCreate(
                    occurrenceDate,
                    targetDate,
                    targetDateTime,
                    true,
                    exception.getReason()
            );
        }

        LocalDate scheduledDate = occurrenceDate;
        LocalDateTime dueDateTime = null;

        if (template.getDefaultDueTime() != null) {
            dueDateTime = scheduledDate.atTime(template.getDefaultDueTime());
        }

        return SpawnCandidate.toCreate(
                occurrenceDate,
                scheduledDate,
                dueDateTime,
                false,
                null
        );
    }

    private TaskOccurrenceException findException(
            List<TaskOccurrenceException> exceptions,
            LocalDate occurrenceDate
    ) {
        return exceptions.stream()
                .filter(exception -> occurrenceDate.equals(exception.getOccurrenceDate()))
                .findFirst()
                .orElse(null);
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

    public record SpawnPlan(
            List<SpawnCandidate> candidates
    ) {
        public static SpawnPlan empty() {
            return new SpawnPlan(List.of());
        }

        public List<SpawnCandidate> creatable() {
            return candidates.stream()
                    .filter(SpawnCandidate::shouldCreate)
                    .toList();
        }

        public List<SpawnCandidate> skipped() {
            return candidates.stream()
                    .filter(candidate -> candidate.decision() == SpawnDecision.SKIPPED)
                    .toList();
        }

        public List<SpawnCandidate> existing() {
            return candidates.stream()
                    .filter(candidate -> candidate.decision() == SpawnDecision.ALREADY_EXISTS)
                    .toList();
        }
    }

    public record SpawnCandidate(
            LocalDate occurrenceDate,
            LocalDate scheduledDate,
            LocalDateTime dueDateTime,
            SpawnDecision decision,
            boolean rescheduled,
            String reason
    ) {
        public static SpawnCandidate toCreate(
                LocalDate occurrenceDate,
                LocalDate scheduledDate,
                LocalDateTime dueDateTime,
                boolean rescheduled,
                String reason
        ) {
            return new SpawnCandidate(
                    occurrenceDate,
                    scheduledDate,
                    dueDateTime,
                    SpawnDecision.CREATE,
                    rescheduled,
                    reason
            );
        }

        public static SpawnCandidate skipped(
                LocalDate occurrenceDate,
                String reason
        ) {
            return new SpawnCandidate(
                    occurrenceDate,
                    null,
                    null,
                    SpawnDecision.SKIPPED,
                    false,
                    reason
            );
        }

        public static SpawnCandidate existing(LocalDate occurrenceDate) {
            return new SpawnCandidate(
                    occurrenceDate,
                    null,
                    null,
                    SpawnDecision.ALREADY_EXISTS,
                    false,
                    "Instance already exists"
            );
        }

        public boolean shouldCreate() {
            return decision == SpawnDecision.CREATE;
        }
    }

    public enum SpawnDecision {
        CREATE,
        SKIPPED,
        ALREADY_EXISTS
    }
}