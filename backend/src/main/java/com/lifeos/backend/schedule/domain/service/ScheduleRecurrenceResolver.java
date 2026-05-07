package com.lifeos.backend.schedule.domain.service;

import com.lifeos.backend.schedule.domain.ScheduleBlock;
import com.lifeos.backend.schedule.domain.ScheduleRecurrenceType;
import org.springframework.stereotype.Component;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.Set;
import java.util.stream.Collectors;

@Component
public class ScheduleRecurrenceResolver {

    public boolean occursOn(ScheduleBlock block, LocalDate date) {
        // If it's paused or archived, it mathematically does NOT occur.
        if (block == null || date == null || !block.isActiveBlock() || block.isArchived()) return false;
        if (block.getRecurrenceStartDate() == null) return false;

        if (date.isBefore(block.getRecurrenceStartDate())) return false;
        if (block.getRecurrenceEndDate() != null && date.isAfter(block.getRecurrenceEndDate())) return false;

        ScheduleRecurrenceType type = block.getRecurrenceType();
        if (type == null) type = ScheduleRecurrenceType.NONE;

        return switch (type) {
            case NONE -> date.isEqual(block.getRecurrenceStartDate());
            case DAILY -> true;
            case WEEKLY -> date.getDayOfWeek() == block.getRecurrenceStartDate().getDayOfWeek();
            case CUSTOM_WEEKLY -> occursOnCustomWeekly(block, date);
            case MONTHLY -> date.getDayOfMonth() == block.getRecurrenceStartDate().getDayOfMonth();
        };
    }

    private boolean occursOnCustomWeekly(ScheduleBlock block, LocalDate date) {
        if (block.getRecurrenceDaysOfWeek() == null || block.getRecurrenceDaysOfWeek().isBlank()) return false;

        Set<DayOfWeek> allowedDays = Arrays.stream(block.getRecurrenceDaysOfWeek().split(","))
                .map(String::trim)
                .filter(s -> !s.isBlank())
                .map(String::toUpperCase)
                .map(DayOfWeek::valueOf)
                .collect(Collectors.toSet());

        return allowedDays.contains(date.getDayOfWeek());
    }
}