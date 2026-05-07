package com.lifeos.backend.task.api.request;

import com.lifeos.backend.task.domain.enums.TaskMode;
import com.lifeos.backend.task.domain.enums.TaskPriority;
import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
import com.lifeos.backend.task.domain.enums.TaskStatus;
import jakarta.validation.constraints.Pattern;
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
    private Boolean clearDueDate;
    private Boolean clearDueDateTime;
    private Boolean clearRecurrence;
    private Boolean clearLinkedScheduleBlock;
    private TaskRecurrenceType recurrenceType;
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