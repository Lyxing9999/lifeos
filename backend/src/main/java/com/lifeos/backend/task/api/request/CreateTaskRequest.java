package com.lifeos.backend.task.api.request;

import com.lifeos.backend.task.domain.TaskMode;
import com.lifeos.backend.task.domain.TaskPriority;
import com.lifeos.backend.task.domain.TaskRecurrenceType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Set;
import java.util.UUID;

@Getter
@Setter
public class CreateTaskRequest {

    @NotNull
    private UUID userId;

    @NotBlank
    private String title;

    private String description;
    private String category;

    private TaskMode taskMode = TaskMode.STANDARD;
    private TaskPriority priority = TaskPriority.MEDIUM;

    private LocalDate dueDate;
    private LocalDateTime dueDateTime;
    private Integer progressPercent;

    private TaskRecurrenceType recurrenceType = TaskRecurrenceType.NONE;
    private LocalDate recurrenceStartDate;
    private LocalDate recurrenceEndDate;
    private String recurrenceDaysOfWeek;

    private UUID linkedScheduleBlockId;

    private Set<String> tags;
}