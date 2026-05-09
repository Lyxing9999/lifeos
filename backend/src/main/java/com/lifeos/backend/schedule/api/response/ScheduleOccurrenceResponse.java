package com.lifeos.backend.schedule.api.response;

import com.lifeos.backend.schedule.domain.enums.ScheduleBlockType;
import com.lifeos.backend.schedule.domain.enums.ScheduleOccurrenceStatus;
import com.lifeos.backend.schedule.domain.enums.ScheduleSourceType;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Builder
public class ScheduleOccurrenceResponse {

    private UUID id;
    private UUID userId;
    private UUID templateId;

    private String title;
    private ScheduleBlockType type;
    private String description;

    private LocalDate occurrenceDate;
    private LocalDate scheduledDate;

    private LocalDateTime startDateTime;
    private LocalDateTime endDateTime;

    private ScheduleOccurrenceStatus status;
    private ScheduleOccurrenceStatus previousStatus;
    private ScheduleSourceType sourceType;

    private UUID linkedTaskInstanceId;
    private UUID linkedTaskTemplateId;

    private UUID rescheduledFromOccurrenceId;
    private UUID rescheduledToOccurrenceId;

    private Instant activatedAt;
    private Instant expiredAt;
    private Instant cancelledAt;
    private Instant skippedAt;
    private Instant rescheduledAt;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private Boolean open;
    private Boolean finalState;
    private Boolean planned;
    private Boolean active;
    private Boolean expired;
    private Boolean cancelled;
    private Boolean skipped;
    private Boolean rescheduled;

    /**
     * Useful for Timeline / Today grouping.
     */
    private String timelineLane;
}