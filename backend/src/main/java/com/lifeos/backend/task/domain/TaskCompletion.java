package com.lifeos.backend.task.domain;

import com.lifeos.backend.common.base.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(
        name = "task_completions",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_task_completions_task_date",
                        columnNames = {"taskId", "completionDate"}
                )
        },
        indexes = {
                @Index(name = "idx_task_completions_user_date", columnList = "userId,completionDate"),
                @Index(name = "idx_task_completions_task_date", columnList = "taskId,completionDate")
        }
)
@Getter
@Setter
public class TaskCompletion extends BaseEntity {

    @Column(nullable = false)
    private UUID userId;

    @Column(nullable = false)
    private UUID taskId;

    /**
     * User-local date for this completion.
     * Example: user completes daily task for 2026-05-01.
     */
    @Column(nullable = false)
    private LocalDate completionDate;

    /**
     * Absolute instant when the user completed this occurrence.
     */
    @Column(nullable = false)
    private Instant completedAt;

    /**
     * View-cleanup timestamp.
     *
     * This hides the recurring occurrence from Done for this date,
     * but keeps it available for History / analytics.
     */
    private Instant clearedAt;

    public void clearFromDone() {
        this.clearedAt = Instant.now();
    }

    public void restoreToDone() {
        this.clearedAt = null;
    }

    public boolean isCleared() {
        return this.clearedAt != null;
    }
}