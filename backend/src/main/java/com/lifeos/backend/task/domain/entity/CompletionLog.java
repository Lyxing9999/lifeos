package com.lifeos.backend.task.domain.entity;

import com.lifeos.backend.common.base.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

/**
 * Completion evidence.
 *
 * TaskInstance.status = COMPLETED is the current state.
 * CompletionLog records completion facts for history/analytics.
 */
@Entity
@Table(
        name = "task_completion_logs",
        indexes = {
                @Index(name = "idx_task_completion_logs_user_date", columnList = "user_id,achieved_date"),
                @Index(name = "idx_task_completion_logs_instance", columnList = "task_instance_id"),
                @Index(name = "idx_task_completion_logs_template", columnList = "template_id")
        }
)
@Getter
@Setter
public class CompletionLog extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "template_id")
    private UUID templateId;

    @Column(name = "task_instance_id", nullable = false)
    private UUID taskInstanceId;

    @Column(name = "completed_at", nullable = false)
    private Instant completedAt;

    /**
     * User-local date this completion counts for.
     */
    @Column(name = "achieved_date", nullable = false)
    private LocalDate achievedDate;

    /**
     * USER, SYSTEM, IMPORT, AI, etc.
     */
    @Column(nullable = false, length = 40)
    private String source = "USER";

    @Column(length = 1000)
    private String note;

    public static CompletionLog create(
            UUID userId,
            UUID templateId,
            UUID taskInstanceId,
            Instant completedAt,
            LocalDate achievedDate,
            String source
    ) {
        CompletionLog log = new CompletionLog();
        log.setUserId(userId);
        log.setTemplateId(templateId);
        log.setTaskInstanceId(taskInstanceId);
        log.setCompletedAt(completedAt);
        log.setAchievedDate(achievedDate);
        log.setSource(source == null ? "USER" : source);
        return log;
    }
}