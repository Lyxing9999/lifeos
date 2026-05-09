package com.lifeos.backend.task.domain.service;

import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
import com.lifeos.backend.task.domain.valueobject.TaskRecurrenceRule;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class TaskRecurrenceResolverTest {

    private TaskRecurrenceResolver resolver;
    private TaskInstance mockTask;

    @BeforeEach
    void setUp() {
        resolver = new TaskRecurrenceResolver();
        mockTask = mock(TaskInstance.class);
    }

    @Test
    void customWeekly_shouldReturnTrueForConfiguredDays() {
        // Start date is Monday
        LocalDate startDate = LocalDate.of(2026, 4, 20);
        TaskRecurrenceRule rule = new TaskRecurrenceRule(
                TaskRecurrenceType.CUSTOM_WEEKLY,
                startDate,
                null,
                "MONDAY,WEDNESDAY,FRIDAY"
        );
        when(mockTask.getRecurrenceRule()).thenReturn(rule);

        // Monday (Same as start date)
        assertTrue(resolver.isRelevantOn(mockTask, LocalDate.of(2026, 4, 20)));
        // Wednesday
        assertTrue(resolver.isRelevantOn(mockTask, LocalDate.of(2026, 4, 22)));
        // Friday
        assertTrue(resolver.isRelevantOn(mockTask, LocalDate.of(2026, 4, 24)));
    }

    @Test
    void customWeekly_shouldReturnFalseForNonConfiguredDays() {
        LocalDate startDate = LocalDate.of(2026, 4, 20);
        TaskRecurrenceRule rule = new TaskRecurrenceRule(
                TaskRecurrenceType.CUSTOM_WEEKLY,
                startDate,
                null,
                "MONDAY,WEDNESDAY,FRIDAY"
        );
        when(mockTask.getRecurrenceRule()).thenReturn(rule);

        // Tuesday
        assertFalse(resolver.isRelevantOn(mockTask, LocalDate.of(2026, 4, 21)));
        // Thursday
        assertFalse(resolver.isRelevantOn(mockTask, LocalDate.of(2026, 4, 23)));
        // Saturday
        assertFalse(resolver.isRelevantOn(mockTask, LocalDate.of(2026, 4, 25)));
    }

    @Test
    void customWeekly_shouldHandleMessySpacingAndCasing() {
        LocalDate startDate = LocalDate.of(2026, 4, 20);
        TaskRecurrenceRule rule = new TaskRecurrenceRule(
                TaskRecurrenceType.CUSTOM_WEEKLY,
                startDate,
                null,
                " monday,  TUESDAY , wednesday  ,,"
        );
        when(mockTask.getRecurrenceRule()).thenReturn(rule);

        assertTrue(resolver.isRelevantOn(mockTask, LocalDate.of(2026, 4, 20))); // Monday
        assertTrue(resolver.isRelevantOn(mockTask, LocalDate.of(2026, 4, 21))); // Tuesday
        assertTrue(resolver.isRelevantOn(mockTask, LocalDate.of(2026, 4, 22))); // Wednesday
        assertFalse(resolver.isRelevantOn(mockTask, LocalDate.of(2026, 4, 23))); // Thursday
    }

    @Test
    void customWeekly_shouldReturnFalseIfDaysOfWeekIsEmptyOrNull() {
        LocalDate startDate = LocalDate.of(2026, 4, 20);

        TaskRecurrenceRule emptyRule = new TaskRecurrenceRule(
                TaskRecurrenceType.CUSTOM_WEEKLY, startDate, null, ""
        );
        when(mockTask.getRecurrenceRule()).thenReturn(emptyRule);
        assertFalse(resolver.isRelevantOn(mockTask, LocalDate.of(2026, 4, 20)));

        TaskRecurrenceRule nullRule = new TaskRecurrenceRule(
                TaskRecurrenceType.CUSTOM_WEEKLY, startDate, null, null
        );
        when(mockTask.getRecurrenceRule()).thenReturn(nullRule);
        assertFalse(resolver.isRelevantOn(mockTask, LocalDate.of(2026, 4, 20)));
    }

    @Test
    void customWeekly_shouldRespectEndDates() {
        LocalDate startDate = LocalDate.of(2026, 4, 20); // Monday
        LocalDate endDate = LocalDate.of(2026, 4, 24);   // Friday

        TaskRecurrenceRule rule = new TaskRecurrenceRule(
                TaskRecurrenceType.CUSTOM_WEEKLY,
                startDate,
                endDate,
                "MONDAY,WEDNESDAY,FRIDAY"
        );
        when(mockTask.getRecurrenceRule()).thenReturn(rule);

        // Before start date
        assertFalse(resolver.isRelevantOn(mockTask, LocalDate.of(2026, 4, 17)));
        // Exactly on end date (Friday)
        assertTrue(resolver.isRelevantOn(mockTask, LocalDate.of(2026, 4, 24)));
        // Next Monday (After end date)
        assertFalse(resolver.isRelevantOn(mockTask, LocalDate.of(2026, 4, 27)));
    }
}