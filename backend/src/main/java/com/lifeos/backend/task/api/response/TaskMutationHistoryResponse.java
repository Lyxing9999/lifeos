package com.lifeos.backend.task.api.response;

import com.lifeos.backend.task.domain.enums.MutationType;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.task.domain.enums.TaskTransitionType;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Builder
public class TaskMutationHistoryResponse {

    private UUID id;
    private UUID userId;
    private UUID templateId;
    private UUID taskInstanceId;

    private MutationType mutationType;
    private TaskTransitionType transitionType;

    private TaskInstanceStatus fromStatus;
    private TaskInstanceStatus toStatus;

    private LocalDate fromScheduledDate;
    private LocalDate toScheduledDate;

    private LocalDateTime fromDueDateTime;
    private LocalDateTime toDueDateTime;

    private String reason;
    private String actor;
    private Instant occurredAt;
    private String metadataJson;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}