package com.lifeos.backend.task.infrastructure.event;

import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.event.TaskCompletedEvent;
import com.lifeos.backend.task.domain.event.TaskMissedEvent;
import com.lifeos.backend.task.domain.event.TaskRescheduledEvent;
import com.lifeos.backend.task.domain.event.TaskRolledOverEvent;
import com.lifeos.backend.task.domain.event.TaskSkippedEvent;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class TaskDomainEventPublisher {

    private final ApplicationEventPublisher eventPublisher;
    private final UserTimeService userTimeService;

    public void publishCompleted(TaskInstance instance) {
        requireInstance(instance);

        eventPublisher.publishEvent(
                new TaskCompletedEvent(
                        instance.getUserId(),
                        instance.getId(),
                        instance.getTemplateId(),

                        instance.getTitleSnapshot(),
                        instance.getCategorySnapshot(),
                        statusSnapshot(instance),
                        prioritySnapshot(instance),

                        safeInstant(instance.getCompletedAt()),
                        timezone(instance.getUserId())
                )
        );
    }

    public void publishMissed(TaskInstance instance, String reason) {
        requireInstance(instance);

        eventPublisher.publishEvent(
                new TaskMissedEvent(
                        instance.getUserId(),
                        instance.getId(),
                        instance.getTemplateId(),

                        instance.getTitleSnapshot(),
                        instance.getCategorySnapshot(),
                        statusSnapshot(instance),
                        prioritySnapshot(instance),

                        safeInstant(instance.getMissedAt()),
                        reason,
                        timezone(instance.getUserId())
                )
        );
    }

    public void publishSkipped(TaskInstance instance, String reason) {
        requireInstance(instance);

        eventPublisher.publishEvent(
                new TaskSkippedEvent(
                        instance.getUserId(),
                        instance.getId(),
                        instance.getTemplateId(),

                        instance.getTitleSnapshot(),
                        instance.getCategorySnapshot(),
                        statusSnapshot(instance),
                        prioritySnapshot(instance),

                        safeInstant(instance.getSkippedAt()),
                        reason,
                        timezone(instance.getUserId())
                )
        );
    }

    public void publishRolledOver(
            TaskInstance sourceInstance,
            TaskInstance targetInstance,
            String reason
    ) {
        requireInstance(sourceInstance);

        eventPublisher.publishEvent(
                new TaskRolledOverEvent(
                        sourceInstance.getUserId(),

                        sourceInstance.getId(),
                        targetInstance == null ? null : targetInstance.getId(),
                        sourceInstance.getTemplateId(),

                        sourceInstance.getTitleSnapshot(),
                        sourceInstance.getCategorySnapshot(),
                        statusSnapshot(sourceInstance),
                        prioritySnapshot(sourceInstance),

                        sourceInstance.getScheduledDate(),
                        targetInstance == null ? null : targetInstance.getScheduledDate(),

                        safeInstant(sourceInstance.getRolledOverAt()),
                        reason,
                        timezone(sourceInstance.getUserId())
                )
        );
    }

    public void publishRescheduled(
            TaskInstance instance,
            LocalDate fromScheduledDate,
            LocalDate toScheduledDate,
            LocalDateTime fromDueDateTime,
            LocalDateTime toDueDateTime,
            String reason
    ) {
        requireInstance(instance);

        eventPublisher.publishEvent(
                new TaskRescheduledEvent(
                        instance.getUserId(),
                        instance.getId(),
                        instance.getTemplateId(),

                        instance.getTitleSnapshot(),
                        instance.getCategorySnapshot(),
                        statusSnapshot(instance),
                        prioritySnapshot(instance),

                        fromScheduledDate,
                        toScheduledDate,

                        fromDueDateTime,
                        toDueDateTime,

                        Instant.now(),
                        reason,
                        timezone(instance.getUserId())
                )
        );
    }

    private void requireInstance(TaskInstance instance) {
        if (instance == null) {
            throw new IllegalArgumentException("TaskInstance is required");
        }

        if (instance.getUserId() == null) {
            throw new IllegalArgumentException("TaskInstance userId is required");
        }

        if (instance.getId() == null) {
            throw new IllegalArgumentException("TaskInstance id is required");
        }
    }

    private String statusSnapshot(TaskInstance instance) {
        return instance.getStatus() == null ? null : instance.getStatus().name();
    }

    private String prioritySnapshot(TaskInstance instance) {
        return instance.getPrioritySnapshot() == null
                ? null
                : instance.getPrioritySnapshot().name();
    }

    private Instant safeInstant(Instant instant) {
        return instant == null ? Instant.now() : instant;
    }

    private String timezone(UUID userId) {
        return userTimeService.getUserZoneId(userId).getId();
    }
}