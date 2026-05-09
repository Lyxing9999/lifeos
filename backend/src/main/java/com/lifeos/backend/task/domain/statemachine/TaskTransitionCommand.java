package com.lifeos.backend.task.domain.statemachine;

import com.lifeos.backend.task.domain.enums.TaskTransitionType;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Command object passed into the TaskStateMachine.
 *
 * It supports all lifecycle transitions:
 * - COMPLETE
 * - REOPEN
 * - ROLLOVER
 * - MARK_MISSED
 * - RESCHEDULE
 * - SKIP_OCCURRENCE
 * - PAUSE / RESUME
 * - ARCHIVE / RESTORE
 */
public record TaskTransitionCommand(
        TaskTransitionType transitionType,

        UUID userId,
        UUID taskInstanceId,
        UUID templateId,

        /**
         * Used by RESCHEDULE and ROLLOVER.
         */
        LocalDate targetScheduledDate,

        /**
         * Used by RESCHEDULE and ROLLOVER when exact time matters.
         */
        LocalDateTime targetDueDateTime,

        /**
         * Used by SKIP_OCCURRENCE before/after spawn.
         */
        LocalDate occurrenceDate,

        /**
         * Human/system explanation.
         */
        String reason,

        /**
         * USER, SYSTEM, ENGINE, AI, IMPORT, etc.
         */
        String actor,

        /**
         * Optional flexible extra info.
         */
        String metadataJson
) {

    public static TaskTransitionCommand of(
            TaskTransitionType transitionType,
            UUID userId,
            UUID taskInstanceId
    ) {
        return new TaskTransitionCommand(
                transitionType,
                userId,
                taskInstanceId,
                null,
                null,
                null,
                null,
                null,
                "USER",
                null
        );
    }

    public static TaskTransitionCommand complete(
            UUID userId,
            UUID taskInstanceId
    ) {
        return of(TaskTransitionType.COMPLETE, userId, taskInstanceId);
    }

    public static TaskTransitionCommand reopen(
            UUID userId,
            UUID taskInstanceId,
            String reason
    ) {
        return new TaskTransitionCommand(
                TaskTransitionType.REOPEN,
                userId,
                taskInstanceId,
                null,
                null,
                null,
                null,
                reason,
                "USER",
                null
        );
    }

    public static TaskTransitionCommand rollover(
            UUID userId,
            UUID taskInstanceId,
            LocalDate targetScheduledDate,
            LocalDateTime targetDueDateTime,
            String actor,
            String reason
    ) {
        return new TaskTransitionCommand(
                TaskTransitionType.ROLLOVER,
                userId,
                taskInstanceId,
                null,
                targetScheduledDate,
                targetDueDateTime,
                null,
                reason,
                actor == null ? "ENGINE" : actor,
                null
        );
    }

    public static TaskTransitionCommand markMissed(
            UUID userId,
            UUID taskInstanceId,
            String actor,
            String reason
    ) {
        return new TaskTransitionCommand(
                TaskTransitionType.MARK_MISSED,
                userId,
                taskInstanceId,
                null,
                null,
                null,
                null,
                reason,
                actor == null ? "ENGINE" : actor,
                null
        );
    }

    public static TaskTransitionCommand reschedule(
            UUID userId,
            UUID taskInstanceId,
            LocalDate targetScheduledDate,
            LocalDateTime targetDueDateTime,
            String reason
    ) {
        return new TaskTransitionCommand(
                TaskTransitionType.RESCHEDULE,
                userId,
                taskInstanceId,
                null,
                targetScheduledDate,
                targetDueDateTime,
                null,
                reason,
                "USER",
                null
        );
    }

    public static TaskTransitionCommand skipOccurrence(
            UUID userId,
            UUID taskInstanceId,
            UUID templateId,
            LocalDate occurrenceDate,
            String reason
    ) {
        return new TaskTransitionCommand(
                TaskTransitionType.SKIP_OCCURRENCE,
                userId,
                taskInstanceId,
                templateId,
                null,
                null,
                occurrenceDate,
                reason,
                "USER",
                null
        );
    }

    public TaskTransitionCommand withActor(String newActor) {
        return new TaskTransitionCommand(
                transitionType,
                userId,
                taskInstanceId,
                templateId,
                targetScheduledDate,
                targetDueDateTime,
                occurrenceDate,
                reason,
                newActor,
                metadataJson
        );
    }

    public TaskTransitionCommand withMetadataJson(String newMetadataJson) {
        return new TaskTransitionCommand(
                transitionType,
                userId,
                taskInstanceId,
                templateId,
                targetScheduledDate,
                targetDueDateTime,
                occurrenceDate,
                reason,
                actor,
                newMetadataJson
        );
    }

    public String safeActor() {
        return actor == null || actor.isBlank() ? "USER" : actor.trim();
    }

    public String safeReason() {
        return reason == null || reason.isBlank() ? null : reason.trim();
    }

    public void requireTransitionType() {
        if (transitionType == null) {
            throw new IllegalArgumentException("transitionType is required");
        }
    }

    public void requireTargetScheduledDate() {
        if (targetScheduledDate == null && targetDueDateTime == null) {
            throw new IllegalArgumentException("targetScheduledDate or targetDueDateTime is required");
        }
    }

    public LocalDate resolvedTargetScheduledDate() {
        if (targetScheduledDate != null) {
            return targetScheduledDate;
        }

        if (targetDueDateTime != null) {
            return targetDueDateTime.toLocalDate();
        }

        return null;
    }
}