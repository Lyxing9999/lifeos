package com.lifeos.backend.schedule.api.request;

import com.lifeos.backend.schedule.domain.ScheduleBlockType;
import com.lifeos.backend.schedule.domain.ScheduleRecurrenceType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

@Getter
@Setter
public class CreateScheduleBlockRequest {

    @NotNull
    private UUID userId;

    @NotBlank
    private String title;

    private ScheduleBlockType type = ScheduleBlockType.OTHER;
    private String description;

    @NotNull
    private LocalTime startTime;

    @NotNull
    private LocalTime endTime;

    private ScheduleRecurrenceType recurrenceType = ScheduleRecurrenceType.NONE;
    private String recurrenceDaysOfWeek;
    private LocalDate recurrenceStartDate;
    private LocalDate recurrenceEndDate;
}