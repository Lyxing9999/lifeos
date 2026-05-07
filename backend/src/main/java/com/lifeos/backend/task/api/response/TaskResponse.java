package com.lifeos.backend.task.api.response;

import com.lifeos.backend.task.domain.enums.TaskMode;
import com.lifeos.backend.task.domain.enums.TaskPriority;
import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
import com.lifeos.backend.task.domain.enums.TaskStatus;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Getter
@Setter
@Builder
public class TaskResponse {
    private UUID id;
    private UUID userId;
    private String title;
    private String description;
    private String category;
    private TaskStatus status;
    private TaskMode taskMode;
    private TaskPriority priority;
    private LocalDate dueDate;
    private LocalDateTime dueDateTime;
    private Integer progressPercent;
    private Instant startedAt;
    private Instant completedAt;
    private Boolean archived;
    private LocalDate achievedDate;
    private Instant doneClearedAt;
    private Boolean paused;
    private Instant pausedAt;
    private LocalDate pauseUntil;
    private TaskRecurrenceType recurrenceType;
    private LocalDate recurrenceStartDate;
    private LocalDate recurrenceEndDate;
    private String recurrenceDaysOfWeek;

    private UUID linkedScheduleBlockId;

    private List<TaskTagResponse> tags;
}