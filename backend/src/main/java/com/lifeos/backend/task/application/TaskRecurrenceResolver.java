package com.lifeos.backend.task.application;

import com.lifeos.backend.task.domain.Task;
import com.lifeos.backend.task.domain.TaskRecurrenceType;
import org.springframework.stereotype.Component;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.Set;
import java.util.stream.Collectors;

@Component
public class TaskRecurrenceResolver {

    public boolean isRelevantOn(Task task, LocalDate date) {
        if (Boolean.TRUE.equals(task.getArchived())) {
            return false;
        }

        if (task.getRecurrenceType() == null || task.getRecurrenceType() == TaskRecurrenceType.NONE) {
            return task.getDueDate() != null && task.getDueDate().equals(date);
        }

        if (task.getRecurrenceStartDate() == null) {
            return false;
        }

        if (date.isBefore(task.getRecurrenceStartDate())) {
            return false;
        }

        if (task.getRecurrenceEndDate() != null && date.isAfter(task.getRecurrenceEndDate())) {
            return false;
        }

        return switch (task.getRecurrenceType()) {
            case DAILY -> true;
            case CUSTOM_WEEKLY -> matchesCustomWeekly(task, date.getDayOfWeek());
            case NONE -> task.getDueDate() != null && task.getDueDate().equals(date);
        };
    }

    private boolean matchesCustomWeekly(Task task, DayOfWeek dayOfWeek) {
        if (task.getRecurrenceDaysOfWeek() == null || task.getRecurrenceDaysOfWeek().isBlank()) {
            return false;
        }

        Set<String> allowed = Arrays.stream(task.getRecurrenceDaysOfWeek().split(","))
                .map(String::trim)
                .filter(s -> !s.isBlank())
                .map(String::toUpperCase)
                .collect(Collectors.toSet());

        return allowed.contains(dayOfWeek.name());
    }
}