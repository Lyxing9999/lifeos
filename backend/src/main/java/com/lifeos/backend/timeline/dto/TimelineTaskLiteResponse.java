package com.lifeos.backend.timeline.dto;

import com.lifeos.backend.task.domain.TaskMode;
import com.lifeos.backend.task.domain.TaskPriority;
import com.lifeos.backend.task.domain.TaskStatus;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Getter
@Builder
public class TimelineTaskLiteResponse {
    private UUID id;
    private String title;
    private TaskStatus status;
    private TaskMode taskMode;
    private TaskPriority priority;
    private Integer progressPercent;
    private String category;
    private LocalDate dueDate;
    private LocalDateTime dueDateTime;
    private Instant completedAt;
    private UUID linkedScheduleBlockId;
    private List<String> tags;
}