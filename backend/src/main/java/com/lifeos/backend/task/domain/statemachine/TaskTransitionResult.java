package com.lifeos.backend.task.domain.statemachine;

import com.lifeos.backend.task.domain.entity.MutationHistory;
import com.lifeos.backend.task.domain.enums.MutationType;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.task.domain.enums.TaskTransitionType;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Result of one lifecycle transition.
 *
 * The transition mutates TaskInstance.
 * This result describes what changed and can create MutationHistory.
 */
public record TaskTransitionResult(
        UUID userId,
        UUID templateId,
        UUID taskInstanceId,

        TaskTransitionType transitionType,
        MutationType mutationType,

        TaskInstanceStatus fromStatus,
        TaskInstanceStatus toStatus,

        LocalDate fromScheduledDate,
        LocalDate toScheduledDate,

        LocalDateTime fromDueDateTime,
        LocalDateTime toDueDateTime,

        String actor,
        String reason,
        String metadataJson,

        Instant occurredAt,

        boolean changed,
        List<String> messages
) {

    public static TaskTransitionResult changed(
            UUID userId,
            UUID templateId,
            UUID taskInstanceId,
            TaskTransitionType transitionType,
            MutationType mutationType,
            TaskInstanceStatus fromStatus,
            TaskInstanceStatus toStatus,
            String actor,
            String reason
    ) {
        return new TaskTransitionResult(
                userId,
                templateId,
                taskInstanceId,
                transitionType,
                mutationType,
                fromStatus,
                toStatus,
                null,
                null,
                null,
                null,
                safeActor(actor),
                reason,
                null,
                Instant.now(),
                true,
                List.of()
        );
    }

    public static TaskTransitionResult changedWithSchedule(
            UUID userId,
            UUID templateId,
            UUID taskInstanceId,
            TaskTransitionType transitionType,
            MutationType mutationType,
            TaskInstanceStatus fromStatus,
            TaskInstanceStatus toStatus,
            LocalDate fromScheduledDate,
            LocalDate toScheduledDate,
            LocalDateTime fromDueDateTime,
            LocalDateTime toDueDateTime,
            String actor,
            String reason,
            String metadataJson
    ) {
        return new TaskTransitionResult(
                userId,
                templateId,
                taskInstanceId,
                transitionType,
                mutationType,
                fromStatus,
                toStatus,
                fromScheduledDate,
                toScheduledDate,
                fromDueDateTime,
                toDueDateTime,
                safeActor(actor),
                reason,
                metadataJson,
                Instant.now(),
                true,
                List.of()
        );
    }

    public static TaskTransitionResult unchanged(
            UUID userId,
            UUID templateId,
            UUID taskInstanceId,
            TaskTransitionType transitionType,
            String message
    ) {
        return new TaskTransitionResult(
                userId,
                templateId,
                taskInstanceId,
                transitionType,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                "SYSTEM",
                null,
                null,
                Instant.now(),
                false,
                message == null ? List.of() : List.of(message)
        );
    }

    public MutationHistory toMutationHistory() {
        if (!changed) {
            throw new IllegalStateException("Cannot create MutationHistory for unchanged transition");
        }

        MutationHistory history = MutationHistory.lifecycle(
                userId,
                templateId,
                taskInstanceId,
                mutationType,
                transitionType,
                fromStatus,
                toStatus,
                actor,
                reason
        );

        history.setFromScheduledDate(fromScheduledDate);
        history.setToScheduledDate(toScheduledDate);
        history.setFromDueDateTime(fromDueDateTime);
        history.setToDueDateTime(toDueDateTime);
        history.setMetadataJson(metadataJson);
        history.setOccurredAt(occurredAt);

        return history;
    }

    private static String safeActor(String actor) {
        return actor == null || actor.isBlank() ? "USER" : actor.trim();
    }
}