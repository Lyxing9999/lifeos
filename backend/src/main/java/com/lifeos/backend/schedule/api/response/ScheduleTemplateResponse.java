package com.lifeos.backend.schedule.api.response;

import com.lifeos.backend.schedule.domain.enums.ScheduleBlockType;
import com.lifeos.backend.schedule.domain.enums.ScheduleRecurrenceType;
import com.lifeos.backend.schedule.domain.enums.ScheduleTemplateStatus;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.UUID;

@Getter
@Builder
public class ScheduleTemplateResponse {

    private UUID id;
    private UUID userId;

    private String title;
    private String description;
    private ScheduleBlockType type;

    private LocalTime startTime;
    private LocalTime endTime;

    private ScheduleTemplateStatus status;

    private ScheduleRecurrenceType recurrenceType;
    private String recurrenceDaysOfWeek;
    private LocalDate recurrenceStartDate;
    private LocalDate recurrenceEndDate;

    private String colorKey;
    private UUID externalCalendarId;

    private Instant archivedAt;
    private Instant pausedAt;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private Boolean activeTemplate;
    private Boolean paused;
    private Boolean archived;
    private Boolean recurring;
    private Boolean oneTime;
    private Boolean canSpawnOccurrences;
}