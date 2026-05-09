package com.lifeos.backend.task.domain.service;

import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Component
public class TaskInstanceStatusResolver {

    public TaskInstanceStatus resolveInitialStatus(
            LocalDate scheduledDate,
            LocalDate userToday
    ) {
        if (scheduledDate == null) {
            return TaskInstanceStatus.INBOX;
        }

        if (userToday == null) {
            return TaskInstanceStatus.SCHEDULED;
        }

        if (scheduledDate.isBefore(userToday)) {
            return TaskInstanceStatus.OVERDUE;
        }

        if (scheduledDate.equals(userToday)) {
            return TaskInstanceStatus.DUE_TODAY;
        }

        return TaskInstanceStatus.SCHEDULED;
    }

    public TaskInstanceStatus resolveInitialStatus(
            LocalDate scheduledDate,
            LocalDateTime dueDateTime,
            LocalDate userToday
    ) {
        LocalDate effectiveDate = scheduledDate;

        if (effectiveDate == null && dueDateTime != null) {
            effectiveDate = dueDateTime.toLocalDate();
        }

        return resolveInitialStatus(effectiveDate, userToday);
    }

    public TaskInstanceStatus resolveAfterReschedule(
            LocalDate targetScheduledDate,
            LocalDateTime targetDueDateTime,
            LocalDate userToday
    ) {
        return resolveInitialStatus(
                targetScheduledDate,
                targetDueDateTime,
                userToday
        );
    }

    public TaskInstanceStatus resolveAfterReopen(
            TaskInstance instance,
            LocalDate userToday
    ) {
        if (instance == null) {
            throw new IllegalArgumentException("TaskInstance is required");
        }

        return resolveInitialStatus(
                instance.getScheduledDate(),
                instance.getDueDateTime(),
                userToday
        );
    }

    public TaskInstanceStatus resolveRestoreTarget(
            TaskInstance instance,
            LocalDate userToday
    ) {
        if (instance == null) {
            throw new IllegalArgumentException("TaskInstance is required");
        }

        if (instance.getPreviousStatus() != null) {
            return instance.getPreviousStatus();
        }

        return resolveInitialStatus(
                instance.getScheduledDate(),
                instance.getDueDateTime(),
                userToday
        );
    }

    public boolean isVisibleActive(TaskInstance instance) {
        if (instance == null || instance.getStatus() == null) {
            return false;
        }

        return instance.getStatus() == TaskInstanceStatus.INBOX
                || instance.getStatus() == TaskInstanceStatus.SCHEDULED
                || instance.getStatus() == TaskInstanceStatus.DUE_TODAY
                || instance.getStatus() == TaskInstanceStatus.IN_PROGRESS
                || instance.getStatus() == TaskInstanceStatus.OVERDUE;
    }

    public boolean isTodayRelevant(
            TaskInstance instance,
            LocalDate selectedDate
    ) {
        if (instance == null || selectedDate == null) {
            return false;
        }

        if (instance.getStatus() == TaskInstanceStatus.COMPLETED) {
            return selectedDate.equals(instance.getAchievedDate());
        }

        if (!isVisibleActive(instance)) {
            return false;
        }

        LocalDate scheduledDate = instance.getScheduledDate();

        if (scheduledDate == null && instance.getDueDateTime() != null) {
            scheduledDate = instance.getDueDateTime().toLocalDate();
        }

        if (scheduledDate == null) {
            return instance.getStatus() == TaskInstanceStatus.INBOX;
        }

        return scheduledDate.equals(selectedDate)
                || scheduledDate.isBefore(selectedDate);
    }
}