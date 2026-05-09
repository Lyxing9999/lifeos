package com.lifeos.backend.task.api.request;

import com.lifeos.backend.task.domain.enums.TaskPriority;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Setter
public class CreateTaskInstanceRequest {

    private UUID userId;

    private String title;
    private String description;
    private TaskPriority priority;
    private String category;

    /**
     * Null means inbox task.
     */
    private LocalDate scheduledDate;

    /**
     * Optional exact due date-time.
     */
    private LocalDateTime dueDateTime;
}