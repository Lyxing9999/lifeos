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
public class TimelineTaskResponse {

    private UUID id;
    private UUID userId;
    private UUID templateId;

    private String title;
    private TaskInstanceStatus status;
    private TaskPriority priority;
    private TaskSourceType sourceType;

    private LocalDate occurrenceDate;
    private LocalDate scheduledDate;
    private LocalDateTime dueDateTime;

    private Instant startedAt;
    private Instant completedAt;
    private LocalDate achievedDate;

    private Instant missedAt;
    private Instant skippedAt;
    private Instant rolledOverAt;

    private UUID linkedScheduleBlockId;
    private UUID rolledOverFromInstanceId;
    private UUID rolledOverToInstanceId;

    /**
     * Useful for timeline grouping.
     * Example: INBOX, SCHEDULED, DUE_TODAY, DONE, MISSED, SKIPPED, OVERDUE.
     */
    private String timelineLane;
}