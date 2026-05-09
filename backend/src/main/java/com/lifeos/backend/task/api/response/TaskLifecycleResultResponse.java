package com.lifeos.backend.task.api.response;

import com.lifeos.backend.task.domain.enums.MutationType;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.task.domain.enums.TaskTransitionType;
import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Response returned after a task lifecycle action.
 *
 * Examples:
 * - complete
 * - reopen
 * - rollover
 * - missed
 * - reschedule
 * - skip occurrence
 * - pause/resume/archive/restore
 */
@Getter
@Builder
public class TaskLifecycleResultResponse {

    /**
     * Main instance affected by the transition.
     *
     * Example:
     * - completed task
     * - missed task
     * - old rolled-over task
     */
    private TaskInstanceResponse instance;

    /**
     * Used by ROLLOVER.
     *
     * Example:
     * Old instance becomes ROLLED_OVER.
     * New carried-over target instance is created for tomorrow.
     */
    private TaskInstanceResponse createdTargetInstance;

    /**
     * Transition metadata.
     */
    private TransitionResponse transition;

    /**
     * Useful for UI toast/debug.
     */
    private List<String> messages;

    /**
     * Convenience flags for frontend.
     */
    private Boolean success;
    private Boolean changed;
    private Boolean hasCreatedTargetInstance;

    @Getter
    @Builder
    public static class TransitionResponse {

        private UUID userId;
        private UUID templateId;
        private UUID taskInstanceId;

        private TaskTransitionType transitionType;
        private MutationType mutationType;

        private TaskInstanceStatus fromStatus;
        private TaskInstanceStatus toStatus;

        private LocalDate fromScheduledDate;
        private LocalDate toScheduledDate;

        private LocalDateTime fromDueDateTime;
        private LocalDateTime toDueDateTime;

        private String actor;
        private String reason;
        private String metadataJson;

        private Instant occurredAt;

        private Boolean changed;
    }
}