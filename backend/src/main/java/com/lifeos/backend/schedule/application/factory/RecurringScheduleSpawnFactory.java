package com.lifeos.backend.schedule.application.factory;

import com.lifeos.backend.schedule.application.factory.RecurringScheduleSpawnFactory.ScheduleSpawnPlan;
import com.lifeos.backend.schedule.domain.entity.ScheduleException;
import com.lifeos.backend.schedule.domain.entity.ScheduleOccurrence;
import com.lifeos.backend.schedule.domain.entity.ScheduleTemplate;
import com.lifeos.backend.schedule.domain.enums.ScheduleExceptionType;
import com.lifeos.backend.schedule.domain.service.ScheduleRecurrenceResolver;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

/**
 * Builds spawn plans for recurring schedule templates.
 *
 * It decides:
 * - which dates should occur
 * - which dates are skipped/cancelled
 * - which dates are rescheduled
 * - which ScheduleOccurrence objects should be created
 *
 * This factory does NOT save to database.
 */
@Component
@RequiredArgsConstructor
public class RecurringScheduleSpawnFactory {

    private final ScheduleOccurrenceFactory occurrenceFactory;
    private final ScheduleRecurrenceResolver recurrenceResolver;

    public ScheduleSpawnPlan buildSpawnPlan(
            ScheduleTemplate template,
            LocalDate windowStart,
            LocalDate windowEnd,
            LocalDateTime userNowLocal,
            Set<LocalDate> existingOccurrenceDates,
            List<ScheduleException> exceptions
    ) {
        validateWindow(windowStart, windowEnd);

        if (template == null || !template.canSpawnOccurrences()) {
            return ScheduleSpawnPlan.empty();
        }

        Set<LocalDate> existingDates = existingOccurrenceDates == null
                ? Set.of()
                : existingOccurrenceDates;

        List<ScheduleException> safeExceptions = exceptions == null
                ? List.of()
                : exceptions;

        List<ScheduleOccurrence> occurrencesToCreate = new ArrayList<>();
        List<LocalDate> skippedDates = new ArrayList<>();
        List<LocalDate> cancelledDates = new ArrayList<>();
        List<LocalDate> ignoredExistingDates = new ArrayList<>();
        List<LocalDate> rescheduledDates = new ArrayList<>();

        List<LocalDate> occurrenceDates = recurrenceResolver.occurrenceDatesBetween(
                template,
                windowStart,
                windowEnd
        );

        for (LocalDate occurrenceDate : occurrenceDates) {
            if (existingDates.contains(occurrenceDate)) {
                ignoredExistingDates.add(occurrenceDate);
                continue;
            }

            ScheduleException exception = findExceptionForDate(
                    safeExceptions,
                    occurrenceDate
            );

            if (exception != null && exception.getType() == ScheduleExceptionType.SKIPPED) {
                skippedDates.add(occurrenceDate);
                continue;
            }

            if (exception != null && exception.getType() == ScheduleExceptionType.CANCELLED) {
                cancelledDates.add(occurrenceDate);
                continue;
            }

            if (exception != null && exception.getType() == ScheduleExceptionType.RESCHEDULED) {
                ScheduleOccurrence rescheduled =
                        createRescheduledOccurrenceFromException(
                                template,
                                occurrenceDate,
                                exception,
                                userNowLocal
                        );

                occurrencesToCreate.add(rescheduled);
                rescheduledDates.add(occurrenceDate);
                continue;
            }

            ScheduleOccurrence normal = createNormalOccurrence(
                    template,
                    occurrenceDate,
                    userNowLocal
            );

            occurrencesToCreate.add(normal);
        }

        return new ScheduleSpawnPlan(
                occurrencesToCreate,
                skippedDates,
                cancelledDates,
                ignoredExistingDates,
                rescheduledDates
        );
    }

    public List<LocalDate> getOccurrenceDates(
            ScheduleTemplate template,
            LocalDate windowStart,
            LocalDate windowEnd
    ) {
        validateWindow(windowStart, windowEnd);

        if (template == null || !template.canSpawnOccurrences()) {
            return List.of();
        }

        return recurrenceResolver.occurrenceDatesBetween(
                template,
                windowStart,
                windowEnd
        );
    }

    public boolean occursOn(
            ScheduleTemplate template,
            LocalDate date
    ) {
        return recurrenceResolver.occursOn(template, date);
    }

    private ScheduleOccurrence createNormalOccurrence(
            ScheduleTemplate template,
            LocalDate occurrenceDate,
            LocalDateTime userNowLocal
    ) {
        LocalDateTime startDateTime = occurrenceDate.atTime(template.getStartTime());
        LocalDateTime endDateTime = occurrenceDate.atTime(template.getEndTime());

        return occurrenceFactory.createFromTemplate(
                template,
                occurrenceDate,
                occurrenceDate,
                startDateTime,
                endDateTime,
                userNowLocal
        );
    }

    private ScheduleOccurrence createRescheduledOccurrenceFromException(
            ScheduleTemplate template,
            LocalDate occurrenceDate,
            ScheduleException exception,
            LocalDateTime userNowLocal
    ) {
        exception.validateRescheduleWindow();

        LocalDateTime targetStart = exception.getRescheduledStartDateTime();
        LocalDateTime targetEnd = exception.getRescheduledEndDateTime();

        return occurrenceFactory.createRescheduledFromTemplateException(
                template,
                occurrenceDate,
                targetStart,
                targetEnd,
                userNowLocal
        );
    }

    private ScheduleException findExceptionForDate(
            List<ScheduleException> exceptions,
            LocalDate date
    ) {
        return exceptions.stream()
                .filter(exception -> date.equals(exception.getOccurrenceDate()))
                .findFirst()
                .orElse(null);
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

    public record ScheduleSpawnPlan(
            List<ScheduleOccurrence> occurrencesToCreate,
            List<LocalDate> skippedDates,
            List<LocalDate> cancelledDates,
            List<LocalDate> ignoredExistingDates,
            List<LocalDate> rescheduledDates
    ) {
        public static ScheduleSpawnPlan empty() {
            return new ScheduleSpawnPlan(
                    List.of(),
                    List.of(),
                    List.of(),
                    List.of(),
                    List.of()
            );
        }

        public boolean hasOccurrencesToCreate() {
            return occurrencesToCreate != null && !occurrencesToCreate.isEmpty();
        }

        public int totalBlockedByException() {
            return size(skippedDates) + size(cancelledDates);
        }

        private static int size(List<?> list) {
            return list == null ? 0 : list.size();
        }
    }
}