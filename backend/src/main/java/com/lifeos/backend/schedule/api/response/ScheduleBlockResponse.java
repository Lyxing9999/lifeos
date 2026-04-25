package com.lifeos.backend.schedule.api.response;

import com.lifeos.backend.schedule.domain.ScheduleBlockType;
import com.lifeos.backend.schedule.domain.ScheduleRecurrenceType;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

@Getter
@Builder
public class ScheduleBlockResponse {
    private UUID id;
    private UUID userId;
    private String title;
    private ScheduleBlockType type;
    private String description;
    private LocalTime startTime;
    private LocalTime endTime;
    private ScheduleRecurrenceType recurrenceType;
    private String recurrenceDaysOfWeek;
    private LocalDate recurrenceStartDate;
    private LocalDate recurrenceEndDate;
    private Boolean active;
}