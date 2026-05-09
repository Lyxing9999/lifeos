package com.lifeos.backend.schedule.api.request;

import com.lifeos.backend.schedule.domain.enums.ScheduleBlockType;
import com.lifeos.backend.schedule.domain.enums.ScheduleRecurrenceType;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

@Getter
@Setter
public class CreateScheduleTemplateRequest {

    private UUID userId;

    private String title;
    private String description;
    private ScheduleBlockType type;

    private LocalTime startTime;
    private LocalTime endTime;

    private ScheduleRecurrenceType recurrenceType;
    private LocalDate recurrenceStartDate;
    private LocalDate recurrenceEndDate;
    private String recurrenceDaysOfWeek;

    private String colorKey;
    private UUID externalCalendarId;
}