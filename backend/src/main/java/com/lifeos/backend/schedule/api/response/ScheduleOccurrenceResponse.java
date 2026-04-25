package com.lifeos.backend.schedule.api.response;

import com.lifeos.backend.schedule.domain.ScheduleBlockType;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Builder
public class ScheduleOccurrenceResponse {
    private UUID scheduleBlockId;
    private UUID userId;
    private String title;
    private ScheduleBlockType type;
    private LocalDate occurrenceDate;
    private LocalDateTime startDateTime;
    private LocalDateTime endDateTime;
}