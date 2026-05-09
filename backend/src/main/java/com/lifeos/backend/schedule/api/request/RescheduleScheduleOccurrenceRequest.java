package com.lifeos.backend.schedule.api.request;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Setter
public class RescheduleScheduleOccurrenceRequest {

    private UUID userId;

    /**
     * Used for existing occurrence reschedule.
     */
    private UUID occurrenceId;

    /**
     * Used for future occurrence before spawn.
     */
    private UUID templateId;
    private LocalDate occurrenceDate;

    private LocalDateTime targetStartDateTime;
    private LocalDateTime targetEndDateTime;

    private String reason;
}