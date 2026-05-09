package com.lifeos.backend.task.api.response;

import com.lifeos.backend.task.domain.enums.MissedPolicy;
import com.lifeos.backend.task.domain.enums.OverduePolicy;
import com.lifeos.backend.task.domain.enums.RolloverPolicy;
import com.lifeos.backend.task.domain.enums.TaskPriority;
import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
import com.lifeos.backend.task.domain.enums.TaskTemplateStatus;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.UUID;

@Getter
@Builder
public class TaskTemplateResponse {

    private UUID id;
    private UUID userId;

    private String title;
    private String description;
    private TaskTemplateStatus status;
    private TaskPriority priority;
    private String category;

    private TaskRecurrenceType recurrenceType;
    private LocalDate recurrenceStartDate;
    private LocalDate recurrenceEndDate;
    private String recurrenceDaysOfWeek;

    private LocalTime defaultDueTime;
    private Integer defaultDurationMinutes;
    private UUID linkedScheduleBlockId;

    private OverduePolicy overduePolicy;
    private RolloverPolicy rolloverPolicy;
    private MissedPolicy missedPolicy;

    private Boolean archived;
    private Instant archivedAt;
    private Boolean paused;
    private Instant pausedAt;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private Boolean recurring;
    private Boolean activeTemplate;
}