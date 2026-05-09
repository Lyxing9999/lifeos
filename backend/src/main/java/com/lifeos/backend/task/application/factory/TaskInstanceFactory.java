package com.lifeos.backend.task.application.factory;

import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.entity.TaskTemplate;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.task.domain.enums.TaskPriority;
import com.lifeos.backend.task.domain.enums.TaskSourceType;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Creates TaskInstance objects.
 *
 * This factory does not save to database.
 * Repository save belongs to command service / spawner service.
 */
@Component
public class TaskInstanceFactory {

    /**
     * Create a manual inbox task.
     *
     * Example:
     * User quickly captures: "Buy notebook"
     * No schedule yet.
     */
    public TaskInstance createManualInbox(
            UUID userId,
            String title,
            String description,
            TaskPriority priority,
            String category
    ) {
        TaskInstance instance = new TaskInstance();

        instance.setUserId(userId);
        instance.setTemplateId(null);

        instance.setTitleSnapshot(requireTitle(title));
        instance.setDescriptionSnapshot(description);

        instance.setStatus(TaskInstanceStatus.INBOX);
        instance.setPreviousStatus(null);

        instance.setPrioritySnapshot(priority == null ? TaskPriority.MEDIUM : priority);
        instance.setCategorySnapshot(normalizeCategory(category));

        instance.setSourceType(TaskSourceType.MANUAL);

        instance.setOccurrenceDate(null);
        instance.setScheduledDate(null);
        instance.setDueDateTime(null);

        return instance;
    }

    /**
     * Create a one-time scheduled task.
     *
     * Example:
     * "Submit homework" scheduled for 2026-05-09.
     */
    public TaskInstance createManualScheduled(
            UUID userId,
            String title,
            String description,
            TaskPriority priority,
            String category,
            LocalDate scheduledDate,
            LocalDateTime dueDateTime,
            LocalDate userToday
    ) {
        if (scheduledDate == null && dueDateTime != null) {
            scheduledDate = dueDateTime.toLocalDate();
        }

        TaskInstance instance = createManualInbox(
                userId,
                title,
                description,
                priority,
                category
        );

        instance.setScheduledDate(scheduledDate);
        instance.setDueDateTime(dueDateTime);
        instance.setOccurrenceDate(scheduledDate);

        instance.setStatus(resolveInitialStatus(scheduledDate, userToday));

        return instance;
    }

    /**
     * Create a recurring spawned instance from a template.
     *
     * Template:
     * "Study English every day"
     *
     * Instance:
     * "Study English on 2026-05-08"
     */
    public TaskInstance createFromTemplate(
            TaskTemplate template,
            LocalDate occurrenceDate,
            LocalDate scheduledDate,
            LocalDateTime dueDateTime,
            LocalDate userToday
    ) {
        if (template == null) {
            throw new IllegalArgumentException("TaskTemplate is required");
        }

        if (occurrenceDate == null) {
            throw new IllegalArgumentException("occurrenceDate is required");
        }

        LocalDate safeScheduledDate = scheduledDate == null ? occurrenceDate : scheduledDate;

        TaskInstance instance = new TaskInstance();

        instance.setUserId(template.getUserId());
        instance.setTemplateId(template.getId());

        instance.setTitleSnapshot(requireTitle(template.getTitle()));
        instance.setDescriptionSnapshot(template.getDescription());

        instance.setStatus(resolveInitialStatus(safeScheduledDate, userToday));
        instance.setPreviousStatus(null);

        instance.setPrioritySnapshot(
                template.getPriority() == null
                        ? TaskPriority.MEDIUM
                        : template.getPriority()
        );

        instance.setCategorySnapshot(normalizeCategory(template.getCategory()));

        instance.setSourceType(TaskSourceType.RECURRING_SPAWN);

        instance.setOccurrenceDate(occurrenceDate);
        instance.setScheduledDate(safeScheduledDate);
        instance.setDueDateTime(dueDateTime);

        instance.setLinkedScheduleBlockIdSnapshot(template.getLinkedScheduleBlockId());

        return instance;
    }

    /**
     * Create a target instance for rollover.
     *
     * Old instance remains historical truth.
     * New instance becomes the future actionable item.
     */
    public TaskInstance createRolloverTarget(
            TaskInstance source,
            LocalDate targetDate,
            LocalDateTime targetDueDateTime,
            LocalDate userToday
    ) {
        if (source == null) {
            throw new IllegalArgumentException("source instance is required");
        }

        if (targetDate == null && targetDueDateTime != null) {
            targetDate = targetDueDateTime.toLocalDate();
        }

        if (targetDate == null) {
            throw new IllegalArgumentException("targetDate is required");
        }

        TaskInstance target = new TaskInstance();

        target.setUserId(source.getUserId());
        target.setTemplateId(source.getTemplateId());

        target.setTitleSnapshot(source.getTitleSnapshot());
        target.setDescriptionSnapshot(source.getDescriptionSnapshot());

        target.setStatus(resolveInitialStatus(targetDate, userToday));
        target.setPreviousStatus(null);

        target.setPrioritySnapshot(
                source.getPrioritySnapshot() == null
                        ? TaskPriority.MEDIUM
                        : source.getPrioritySnapshot()
        );

        target.setCategorySnapshot(source.getCategorySnapshot());

        target.setSourceType(TaskSourceType.ROLLOVER);

        /**
         * occurrenceDate keeps original occurrence meaning if it came from a recurring template.
         * scheduledDate becomes the new planned date.
         */
        target.setOccurrenceDate(source.getOccurrenceDate());
        target.setScheduledDate(targetDate);
        target.setDueDateTime(targetDueDateTime);

        target.setLinkedScheduleBlockIdSnapshot(source.getLinkedScheduleBlockIdSnapshot());

        target.setRolledOverFromInstanceId(source.getId());

        return target;
    }

    /**
     * Create an instance from a schedule-linked template.
     *
     * Useful later when schedule blocks generate tasks.
     */
    public TaskInstance createScheduleLinked(
            TaskTemplate template,
            LocalDate occurrenceDate,
            LocalDate scheduledDate,
            LocalDateTime dueDateTime,
            UUID scheduleBlockId,
            LocalDate userToday
    ) {
        TaskInstance instance = createFromTemplate(
                template,
                occurrenceDate,
                scheduledDate,
                dueDateTime,
                userToday
        );

        instance.setSourceType(TaskSourceType.SCHEDULE_LINKED);
        instance.setLinkedScheduleBlockIdSnapshot(scheduleBlockId);

        return instance;
    }

    private TaskInstanceStatus resolveInitialStatus(
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

    private String requireTitle(String title) {
        if (title == null || title.isBlank()) {
            throw new IllegalArgumentException("Task title is required");
        }

        return title.trim();
    }

    private String normalizeCategory(String category) {
        if (category == null || category.isBlank()) {
            return null;
        }

        return category.trim();
    }
}