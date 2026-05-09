package com.lifeos.backend.engine.recurrence;

import com.lifeos.backend.task.domain.entity.TaskTemplate;
import com.lifeos.backend.task.domain.service.TaskRecurrenceResolver;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.util.List;

/**
 * Engine-level recurrence helper.
 *
 * Important:
 * This does not save anything.
 * This only answers recurrence matching questions.
 *
 * For task recurrence, it delegates to TaskRecurrenceResolver.
 * Later, schedule recurrence can have its own resolver but still reuse this pattern.
 */
@Component
@RequiredArgsConstructor
public class RecurrenceMatcher {

    private final TaskRecurrenceResolver taskRecurrenceResolver;

    public boolean matchesTaskTemplate(
            TaskTemplate template,
            LocalDate date
    ) {
        return taskRecurrenceResolver.occursOn(template, date);
    }

    public List<LocalDate> taskOccurrenceDatesBetween(
            TaskTemplate template,
            LocalDate windowStart,
            LocalDate windowEnd
    ) {
        return taskRecurrenceResolver.occurrenceDatesBetween(
                template,
                windowStart,
                windowEnd
        );
    }

    public LocalDate nextTaskOccurrenceOnOrAfter(
            TaskTemplate template,
            LocalDate fromDate
    ) {
        return taskRecurrenceResolver.nextOccurrenceOnOrAfter(
                template,
                fromDate
        );
    }

    public LocalDate nextTaskOccurrenceAfter(
            TaskTemplate template,
            LocalDate afterDate
    ) {
        return taskRecurrenceResolver.nextOccurrenceAfter(
                template,
                afterDate
        );
    }

    public LocalDate previousTaskOccurrenceOnOrBefore(
            TaskTemplate template,
            LocalDate fromDate
    ) {
        return taskRecurrenceResolver.previousOccurrenceOnOrBefore(
                template,
                fromDate
        );
    }
}