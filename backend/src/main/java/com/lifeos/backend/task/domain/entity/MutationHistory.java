package com.lifeos.backend.task.domain.entity;

import com.lifeos.backend.common.base.BaseEntity;
import com.lifeos.backend.task.domain.enums.MutationType;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.task.domain.enums.TaskTransitionType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Index;
import jakarta.persistence.Lob;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Audit trail for task lifecycle changes.
 *
 * This is important for:
 * - dogfooding trust
 * - timeline
 * - debugging
 * - future AI explanations
 */
@Entity
@Table(
        name = "task_mutation_history",
        indexes = {
                @Index(name = "idx_task_mutation_user_time", columnList = "user_id,occurred_at"),
                @Index(name = "idx_task_mutation_template", columnList = "template_id"),
                @Index(name = "idx_task_mutation_instance", columnList = "task_instance_id"),
                @Index(name = "idx_task_mutation_type", columnList = "mutation_type")
        }
)
@Getter
@Setter
public class MutationHistory extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "template_id")
    private UUID templateId;

    @Column(name = "task_instance_id")
    private UUID taskInstanceId;

    @Enumerated(EnumType.STRING)
    @Column(name = "mutation_type", nullable = false, length = 80)
    private MutationType mutationType;

    @Enumerated(EnumType.STRING)
    @Column(name = "transition_type", length = 80)
    private TaskTransitionType transitionType;

    @Enumerated(EnumType.STRING)
    @Column(name = "from_status", length = 40)
    private TaskInstanceStatus fromStatus;

    @Enumerated(EnumType.STRING)
    @Column(name = "to_status", length = 40)
    private TaskInstanceStatus toStatus;

    @Column(name = "from_scheduled_date")
    private LocalDate fromScheduledDate;

    @Column(name = "to_scheduled_date")
    private LocalDate toScheduledDate;

    @Column(name = "from_due_date_time")
    private LocalDateTime fromDueDateTime;

    @Column(name = "to_due_date_time")
    private LocalDateTime toDueDateTime;

    @Column(length = 1000)
    private String reason;

    /**
     * USER, SYSTEM, ENGINE, AI, IMPORT, etc.
     */
    @Column(nullable = false, length = 40)
    private String actor = "USER";

    @Column(name = "occurred_at", nullable = false)
    private Instant occurredAt = Instant.now();

    /**
     * Optional flexible data.
     * Example:
     * {"rolloverTargetDate":"2026-05-09","source":"MidnightRolloverEngine"}
     */
    @Lob
    @Column(name = "metadata_json")
    private String metadataJson;

    public static MutationHistory lifecycle(
            UUID userId,
            UUID templateId,
            UUID taskInstanceId,
            MutationType mutationType,
            TaskTransitionType transitionType,
            TaskInstanceStatus fromStatus,
            TaskInstanceStatus toStatus,
            String actor,
            String reason
    ) {
        MutationHistory history = new MutationHistory();
        history.setUserId(userId);
        history.setTemplateId(templateId);
        history.setTaskInstanceId(taskInstanceId);
        history.setMutationType(mutationType);
        history.setTransitionType(transitionType);
        history.setFromStatus(fromStatus);
        history.setToStatus(toStatus);
        history.setActor(actor == null ? "USER" : actor);
        history.setReason(reason);
        history.setOccurredAt(Instant.now());
        return history;
    }
}