package com.lifeos.backend.task.domain.policy;

import com.lifeos.backend.task.domain.Task;
import com.lifeos.backend.task.domain.enums.TaskStatus;
import com.lifeos.backend.task.domain.service.TaskRecurrenceResolver;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

@Component
@RequiredArgsConstructor
public class TaskSurfacePolicy {

    private final TaskRecurrenceResolver recurrenceResolver;

    /**
     * Task page Due surface.
     *
     * Meaning:
     * - active task
     * - has planning signal:
     * dueDate / dueDateTime / recurrence / linked schedule
     *
     * Important:
     * This is NOT Today.
     * This can include future due tasks because Due owns planned intent.
     */
    public boolean shouldAppearInDue(Task task) {
        if (!isActiveVisibleTask(task)) {
            return false;
        }

        return hasPlanningSignal(task);
    }

    /**
     * Day truth / Today / Timeline / Summary / Score.
     *
     * Meaning:
     * - active task
     * - matters for selected date
     *
     * Rules:
     * - dueDate/dueDateTime appears on due day and overdue days
     * - recurrence appears only on relevant local date
     * - linked schedule alone does not make it date-relevant here unless
     * the task also has due/recurrence signal
     */
    public boolean shouldAppearInDayTruth(Task task, LocalDate selectedDate) {
        if (!isActiveVisibleTask(task) || selectedDate == null) {
            return false;
        }

        LocalDate dueDay = dueDayOf(task);

        if (dueDay != null) {
            return !dueDay.isAfter(selectedDate);
        }

        if (task.isRecurring()) {
            return recurrenceResolver.isRelevantOn(task, selectedDate);
        }

        return false;
    }

    /**
     * Inbox means active capture intent with no planning signal.
     */
    public boolean shouldAppearInInbox(Task task) {
        if (!isActiveVisibleTask(task)) {
            return false;
        }

        return !hasPlanningSignal(task);
    }

    /**
     * All active task library.
     */
    public boolean shouldAppearInAll(Task task) {
        if (task == null || task.isArchived()) {
            return false;
        }

        // We show it even if it's paused.
        return task.getStatus() != TaskStatus.COMPLETED
                && task.getStatus() != TaskStatus.CANCELLED;
    }

    public boolean shouldAppearInPaused(Task task) {
        return task != null
                && !task.isArchived()
                && task.isPaused();
    }

    public boolean shouldAppearInArchived(Task task) {
        return task != null && task.isArchived();
    }

    /**
     * Done tab for selected day.
     *
     * Clear Done hides from Done only.
     */
    public boolean shouldAppearInDone(Task task, LocalDate selectedDate) {
        if (task == null || selectedDate == null) {
            return false;
        }

        if (task.isArchived()) {
            return false;
        }

        if (task.getStatus() != TaskStatus.COMPLETED) {
            return false;
        }

        if (task.isDoneCleared()) {
            return false;
        }

        if (task.getAchievedDate() != null) {
            return task.getAchievedDate().equals(selectedDate);
        }

        LocalDate dueDay = dueDayOf(task);

        return selectedDate.equals(dueDay);
    }

    /**
     * Permanent completed record.
     */
    public boolean shouldAppearInHistory(Task task, LocalDate selectedDate) {
        if (task == null || selectedDate == null) {
            return false;
        }

        if (task.getStatus() != TaskStatus.COMPLETED) {
            return false;
        }

        return selectedDate.equals(task.getAchievedDate());
    }

    private boolean isActiveVisibleTask(Task task) {
        if (task == null) {
            return false;
        }

        if (task.isArchived() || task.isPaused()) {
            return false;
        }

        return task.getStatus() != TaskStatus.COMPLETED
                && task.getStatus() != TaskStatus.CANCELLED;
    }

    private boolean hasPlanningSignal(Task task) {
        return task.getDueDate() != null
                || task.getDueDateTime() != null
                || task.isRecurring()
                || task.getLinkedScheduleBlockId() != null;
    }

    private LocalDate dueDayOf(Task task) {
        if (task.getDueDateTime() != null) {
            return task.getDueDateTime().toLocalDate();
        }

        return task.getDueDate();
    }
}