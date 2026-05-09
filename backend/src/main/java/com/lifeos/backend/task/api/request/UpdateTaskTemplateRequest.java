package com.lifeos.backend.task.api.request;

import com.lifeos.backend.task.domain.enums.MissedPolicy;
import com.lifeos.backend.task.domain.enums.OverduePolicy;
import com.lifeos.backend.task.domain.enums.RolloverPolicy;
import com.lifeos.backend.task.domain.enums.TaskPriority;
import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

@Getter
@Setter
public class UpdateTaskTemplateRequest {

    private UUID userId;

    private String title;
    private String description;
    private TaskPriority priority;
    private String category;

    private TaskRecurrenceType recurrenceType;
    private LocalDate recurrenceStartDate;
    private LocalDate recurrenceEndDate;
    private Boolean clearRecurrenceEndDate = false;
    private String recurrenceDaysOfWeek;

    private LocalTime defaultDueTime;
    private Boolean clearDefaultDueTime = false;

    private Integer defaultDurationMinutes;
    private Boolean clearDefaultDurationMinutes = false;

    private UUID linkedScheduleBlockId;
    private Boolean clearLinkedScheduleBlockId = false;

    private OverduePolicy overduePolicy;
    private RolloverPolicy rolloverPolicy;
    private MissedPolicy missedPolicy;
}