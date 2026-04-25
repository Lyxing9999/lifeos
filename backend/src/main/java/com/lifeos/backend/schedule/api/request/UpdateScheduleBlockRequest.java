package com.lifeos.backend.schedule.api.request;

import com.lifeos.backend.schedule.domain.ScheduleBlockType;
import com.lifeos.backend.schedule.domain.ScheduleRecurrenceType;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalTime;

@Getter
@Setter
public class UpdateScheduleBlockRequest {
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