package com.lifeos.backend.task.domain.entity;

import com.lifeos.backend.common.base.BaseEntity;
import com.lifeos.backend.task.domain.enums.TaskOccurrenceExceptionScope;
import com.lifeos.backend.task.domain.enums.TaskOccurrenceExceptionType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * One-off exception for recurring task occurrences.
 *
 * Required for:
 * - SKIP_OCCURRENCE
 * - RESCHEDULE one occurrence before/after spawn
 */
@Entity
@Table(
        name = "task_occurrence_exceptions",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_task_occurrence_exception_template_date",
                        columnNames = {"template_id", "occurrence_date"}
                )
        },
        indexes = {
                @Index(name = "idx_task_occurrence_exceptions_user", columnList = "user_id"),
                @Index(name = "idx_task_occurrence_exceptions_template", columnList = "template_id"),
                @Index(name = "idx_task_occurrence_exceptions_type", columnList = "type")
        }
)
@Getter
@Setter
public class TaskOccurrenceException extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "template_id", nullable = false)
    private UUID templateId;

    /**
     * Original recurrence date this exception applies to.
     */
    @Column(name = "occurrence_date", nullable = false)
    private LocalDate occurrenceDate;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 40)
    private TaskOccurrenceExceptionType type;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 40)
    private TaskOccurrenceExceptionScope scope = TaskOccurrenceExceptionScope.THIS_OCCURRENCE;

    /**
     * Optional existing instance affected by this exception.
     */
    @Column(name = "task_instance_id")
    private UUID taskInstanceId;

    /**
     * Used when type = RESCHEDULED.
     */
    @Column(name = "rescheduled_date")
    private LocalDate rescheduledDate;

    @Column(name = "rescheduled_date_time")
    private LocalDateTime rescheduledDateTime;

    @Column(length = 1000)
    private String reason;

    @Column(name = "applied_at")
    private Instant appliedAt;

    public boolean isSkipped() {
        return type == TaskOccurrenceExceptionType.SKIPPED;
    }

    public boolean isRescheduled() {
        return type == TaskOccurrenceExceptionType.RESCHEDULED;
    }

    public void markApplied() {
        this.appliedAt = Instant.now();
    }
}