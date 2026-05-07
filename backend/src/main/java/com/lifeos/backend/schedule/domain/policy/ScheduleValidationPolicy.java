package com.lifeos.backend.schedule.domain.policy;

import com.lifeos.backend.schedule.domain.ScheduleBlock;
import com.lifeos.backend.schedule.domain.ScheduleRecurrenceType;
import org.springframework.stereotype.Component;

@Component
public class ScheduleValidationPolicy {

    public void validateForCreateOrUpdate(ScheduleBlock block) {
        if (block.getTitle() == null || block.getTitle().isBlank()) {
            throw new IllegalArgumentException("title is required");
        }
        if (block.getStartTime() == null || block.getEndTime() == null) {
            throw new IllegalArgumentException("startTime and endTime are required");
        }
        if (!block.getStartTime().isBefore(block.getEndTime())) {
            throw new IllegalArgumentException("startTime must be before endTime");
        }
        if (block.getRecurrenceEndDate() != null && block.getRecurrenceEndDate().isBefore(block.getRecurrenceStartDate())) {
            throw new IllegalArgumentException("recurrenceEndDate must be on or after recurrenceStartDate");
        }
        if (block.getRecurrenceType() == ScheduleRecurrenceType.CUSTOM_WEEKLY
                && (block.getRecurrenceDaysOfWeek() == null || block.getRecurrenceDaysOfWeek().isBlank())) {
            throw new IllegalArgumentException("recurrenceDaysOfWeek is required for CUSTOM_WEEKLY");
        }
    }
}