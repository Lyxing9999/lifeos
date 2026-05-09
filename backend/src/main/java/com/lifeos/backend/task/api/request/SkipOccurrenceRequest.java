package com.lifeos.backend.task.api.request;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.util.UUID;

@Getter
@Setter
public class SkipOccurrenceRequest {

    private UUID userId;

    /**
     * For skipping existing spawned instance.
     */
    private UUID taskInstanceId;

    /**
     * For skipping future recurring occurrence before spawn.
     */
    private UUID templateId;
    private LocalDate occurrenceDate;

    private String reason;
}