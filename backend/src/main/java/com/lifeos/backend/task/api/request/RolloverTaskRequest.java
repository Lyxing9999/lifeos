package com.lifeos.backend.task.api.request;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Setter
public class RolloverTaskRequest {

    private UUID userId;

    private LocalDate targetScheduledDate;
    private LocalDateTime targetDueDateTime;

    private String reason;
}