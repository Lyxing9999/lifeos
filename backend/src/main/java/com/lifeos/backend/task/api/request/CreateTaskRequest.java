package com.lifeos.backend.task.api.request;

import com.lifeos.backend.task.domain.enums.TaskMode;
import com.lifeos.backend.task.domain.enums.TaskPriority;
import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Set;
import java.util.UUID;

@Getter
@Setter
public class CreateTaskRequest {

    /*
     * Deprecated for production frontend.
     *
     * Old tests/dev may still set it.
     * Authenticated controller overwrites it from LifeOsPrincipal.
     */
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

    @Pattern(
            regexp = "^$|^[a-zA-Z,\\s]+$",
            message = "Days of week must only contain letters, commas, and spaces"
    )
    private String recurrenceDaysOfWeek;

    private UUID linkedScheduleBlockId;

    private Set<String> tags;
}