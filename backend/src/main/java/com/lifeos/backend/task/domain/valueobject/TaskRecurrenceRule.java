package com.lifeos.backend.task.domain.valueobject;

import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;

@Embeddable
@Getter
@Setter
@NoArgsConstructor
public class TaskRecurrenceRule {

    @Enumerated(EnumType.STRING)
    @Column(name = "recurrence_type", nullable = false)
    private TaskRecurrenceType type = TaskRecurrenceType.NONE;

    @Column(name = "recurrence_start_date")
    private LocalDate startDate;

    @Column(name = "recurrence_end_date")
    private LocalDate endDate;

    @Column(name = "recurrence_days_of_week", length = 120)
    private String daysOfWeek;

    public TaskRecurrenceRule(
            TaskRecurrenceType type,
            LocalDate startDate,
            LocalDate endDate,
            String daysOfWeek
    ) {
        this.type = type != null ? type : TaskRecurrenceType.NONE;
        this.startDate = startDate;
        this.endDate = endDate;
        this.daysOfWeek = daysOfWeek;
    }

    public static TaskRecurrenceRule none() {
        return new TaskRecurrenceRule(TaskRecurrenceType.NONE, null, null, null);
    }

    public boolean isRecurring() {
        return type != null && type != TaskRecurrenceType.NONE;
    }
}