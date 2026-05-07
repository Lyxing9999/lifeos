package com.lifeos.backend.task.domain.service;

import com.lifeos.backend.task.domain.Task;
import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
import com.lifeos.backend.task.domain.valueobject.TaskRecurrenceRule;
import org.springframework.stereotype.Component;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.Set;
import java.util.stream.Collectors;

@Component
public class TaskRecurrenceResolver {

    public boolean isRelevantOn(Task task, LocalDate date) {
        if (task == null || date == null) return false;

        TaskRecurrenceRule rule = task.getRecurrenceRule();

        // If it's recurring, ONLY use recurrence logic. Ignore dueDate.
        if (rule != null && rule.isRecurring()) {
            if (rule.getStartDate() == null) return false;
            if (date.isBefore(rule.getStartDate())) return false;
            if (rule.getEndDate() != null && date.isAfter(rule.getEndDate())) return false;

            return switch (rule.getType()) {
                case DAILY -> true;
                case WEEKLY -> date.getDayOfWeek() == rule.getStartDate().getDayOfWeek();
                case CUSTOM_WEEKLY -> occursOnCustomWeekly(rule, date);
                case MONTHLY -> date.getDayOfMonth() == rule.getStartDate().getDayOfMonth();
                default -> false;
            };
        }

        // Only if NOT recurring do we check one-time due dates
        return isOneTimeTaskRelevantOn(task, date);
    }

    private boolean isOneTimeTaskRelevantOn(Task task, LocalDate date) {
        if (task.getDueDate() != null && date.equals(task.getDueDate())) {
            return true;
        }

        if (task.getDueDateTime() != null && date.equals(task.getDueDateTime().toLocalDate())) {
            return true;
        }

        // Non-recurring tasks are day-relevant only when they carry an explicit due
        // date.
        return false;
    }

    private boolean occursOnCustomWeekly(TaskRecurrenceRule rule, LocalDate date) {
        if (rule.getDaysOfWeek() == null || rule.getDaysOfWeek().isBlank()) {
            return false;
        }

        Set<DayOfWeek> allowedDays = Arrays.stream(rule.getDaysOfWeek().split(","))
                .map(String::trim)
                .filter(value -> !value.isBlank())
                .map(String::toUpperCase)
                .map(DayOfWeek::valueOf)
                .collect(Collectors.toSet());

        return allowedDays.contains(date.getDayOfWeek());
    }
}