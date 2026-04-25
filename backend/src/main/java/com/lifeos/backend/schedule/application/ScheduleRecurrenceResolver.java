package com.lifeos.backend.schedule.application;

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
        if (block == null || date == null) {
            return false;
        }

        if (Boolean.FALSE.equals(block.getActive())) {
            return false;
        }

        if (block.getRecurrenceStartDate() == null) {
            return false;
        }

        if (date.isBefore(block.getRecurrenceStartDate())) {
            return false;
        }

        if (block.getRecurrenceEndDate() != null && date.isAfter(block.getRecurrenceEndDate())) {
            return false;
        }

        ScheduleRecurrenceType recurrenceType = block.getRecurrenceType();
        if (recurrenceType == null) {
            recurrenceType = ScheduleRecurrenceType.NONE;
        }

        return switch (recurrenceType) {
            case NONE -> date.equals(block.getRecurrenceStartDate());

            case DAILY -> true;

            case WEEKLY -> date.getDayOfWeek() == block.getRecurrenceStartDate().getDayOfWeek();

            case CUSTOM_WEEKLY -> occursOnCustomWeekly(block, date);

            case MONTHLY -> date.getDayOfMonth() == block.getRecurrenceStartDate().getDayOfMonth();
        };
    }

    private boolean occursOnCustomWeekly(ScheduleBlock block, LocalDate date) {
        if (block.getRecurrenceDaysOfWeek() == null || block.getRecurrenceDaysOfWeek().isBlank()) {
            return false;
        }

        Set<DayOfWeek> allowedDays = Arrays.stream(block.getRecurrenceDaysOfWeek().split(","))
                .map(String::trim)
                .filter(s -> !s.isBlank())
                .map(DayOfWeek::valueOf)
                .collect(Collectors.toSet());

        return allowedDays.contains(date.getDayOfWeek());
    }
}