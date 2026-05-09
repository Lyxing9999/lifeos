package com.lifeos.backend.schedule.api.response;

import com.lifeos.backend.schedule.domain.enums.ScheduleExceptionType;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Builder
public class ScheduleExceptionResponse {

    private UUID id;
    private UUID userId;
    private UUID templateId;

    private LocalDate occurrenceDate;
    private ScheduleExceptionType type;

    private UUID scheduleOccurrenceId;

    private LocalDate rescheduledDate;
    private LocalDateTime rescheduledStartDateTime;
    private LocalDateTime rescheduledEndDateTime;

    private String reason;
    private Instant appliedAt;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private Boolean skipped;
    private Boolean rescheduled;
    private Boolean cancelled;
    private Boolean preventsOriginalSpawn;
}