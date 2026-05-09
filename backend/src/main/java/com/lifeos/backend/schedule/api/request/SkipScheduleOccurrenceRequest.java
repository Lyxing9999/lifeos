package com.lifeos.backend.schedule.api.request;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.util.UUID;

@Getter
@Setter
public class SkipScheduleOccurrenceRequest {

    private UUID userId;

    /**
     * Used for existing spawned occurrence.
     */
    private UUID occurrenceId;

    /**
     * Used for future occurrence before spawn.
     */
    private UUID templateId;
    private LocalDate occurrenceDate;

    private String reason;
}