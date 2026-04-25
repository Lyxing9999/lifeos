package com.lifeos.backend.task.api.request;

import com.lifeos.backend.task.domain.TaskMode;
import com.lifeos.backend.task.domain.TaskPriority;
import com.lifeos.backend.task.domain.TaskRecurrenceType;
import com.lifeos.backend.task.domain.TaskStatus;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Set;
import java.util.UUID;

@Getter
@Setter
public class UpdateTaskRequest {
    private String title;
    private String description;
    private String category;
    private TaskMode taskMode;
    private TaskPriority priority;
    private TaskStatus status;
    private LocalDate dueDate;
    private LocalDateTime dueDateTime;
    private Integer progressPercent;
    private Boolean archived;

    private TaskRecurrenceType recurrenceType;
    private LocalDate recurrenceStartDate;
    private LocalDate recurrenceEndDate;
    private String recurrenceDaysOfWeek;

    private UUID linkedScheduleBlockId;

    private Set<String> tags;
}