package com.lifeos.backend.task.api.response;

import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.task.domain.enums.TaskPriority;
import com.lifeos.backend.task.domain.enums.TaskSourceType;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Builder
public class TaskInstanceResponse {

    private UUID id;
    private UUID userId;
    private UUID templateId;

    private String title;
    private String description;

    private TaskInstanceStatus status;
    private TaskInstanceStatus previousStatus;

    private TaskPriority priority;
    private String category;
    private TaskSourceType sourceType;

    private LocalDate occurrenceDate;
    private LocalDate scheduledDate;
    private LocalDateTime dueDateTime;

    private UUID linkedScheduleBlockId;

    private Instant startedAt;
    private Instant completedAt;
    private LocalDate achievedDate;
    private Instant doneClearedAt;

    private Instant missedAt;
    private Instant skippedAt;
    private Instant rolledOverAt;

    private UUID rolledOverFromInstanceId;
    private UUID rolledOverToInstanceId;

    private Instant pausedAt;
    private Instant archivedAt;
    private Instant cancelledAt;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private Boolean finalState;
    private Boolean workable;
    private Boolean completed;
    private Boolean overdue;
    private Boolean missed;
    private Boolean skipped;
    private Boolean archived;
    private Boolean paused;
}