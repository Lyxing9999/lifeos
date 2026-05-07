package com.lifeos.backend.task.domain.policy;

import com.lifeos.backend.task.domain.Task;
import com.lifeos.backend.task.domain.enums.TaskMode;
import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
import com.lifeos.backend.task.domain.valueobject.TaskRecurrenceRule;
import org.springframework.stereotype.Component;

@Component
public class TaskValidationPolicy {

    public void validate(Task task) {
        validateProgressRules(task.getTaskMode(), task.getProgressPercent());
        validateRecurrence(task.getRecurrenceRule());
        validatePlanningShape(task);
    }

    public void validateProgressRules(TaskMode taskMode, Integer progressPercent) {
        if (progressPercent == null) {
            return;
        }

        if (taskMode != TaskMode.PROGRESS) {
            throw new IllegalArgumentException("Progress percent is only allowed for PROGRESS tasks");
        }

        if (progressPercent < 0 || progressPercent > 100) {
            throw new IllegalArgumentException("Progress percent must be between 0 and 100");
        }
    }
    private void validatePlanningShape(Task task) {
        if (task == null) {
            return;
        }

        boolean hasDueDate = task.getDueDate() != null || task.getDueDateTime() != null;
        boolean isRecurring = task.isRecurring();

        if (isRecurring && hasDueDate) {
            throw new IllegalArgumentException(
                    "Recurring task must not have dueDate or dueDateTime"
            );
        }

        if (isRecurring) {
            if (task.getRecurrenceRule() == null
                    || task.getRecurrenceRule().getStartDate() == null) {
                throw new IllegalArgumentException(
                        "Recurring task must have recurrenceStartDate"
                );
            }
        }
    }
    public void validateRecurrence(TaskRecurrenceRule recurrenceRule) {
        if (recurrenceRule == null) {
            return;
        }

        TaskRecurrenceType type = recurrenceRule.getType();

        if (type == null) {
            return;
        }

        if (type != TaskRecurrenceType.NONE && recurrenceRule.getStartDate() == null) {
            throw new IllegalArgumentException("recurrenceStartDate is required for recurring task");
        }

        if (recurrenceRule.getEndDate() != null
                && recurrenceRule.getStartDate() != null
                && recurrenceRule.getEndDate().isBefore(recurrenceRule.getStartDate())) {
            throw new IllegalArgumentException("recurrenceEndDate must be on or after recurrenceStartDate");
        }

        if (type == TaskRecurrenceType.CUSTOM_WEEKLY
                && (recurrenceRule.getDaysOfWeek() == null || recurrenceRule.getDaysOfWeek().isBlank())) {
            throw new IllegalArgumentException("recurrenceDaysOfWeek is required for CUSTOM_WEEKLY");
        }
    }
}