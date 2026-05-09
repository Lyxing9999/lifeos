package com.lifeos.backend.task.domain.entity;

import com.lifeos.backend.common.base.BaseEntity;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.task.domain.enums.TaskPriority;
import com.lifeos.backend.task.domain.enums.TaskSourceType;
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
 * TaskInstance = real executable occurrence.
 *
 * Example:
 * Template: "Study English every day"
 * Instance: "Study English on 2026-05-08"
 *
 * State machine should mutate this entity.
 */
@Entity
@Table(
        name = "task_instances",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_task_instances_template_occurrence",
                        columnNames = {"template_id", "occurrence_date"}
                )
        },
        indexes = {
                @Index(name = "idx_task_instances_user_status", columnList = "user_id,status"),
                @Index(name = "idx_task_instances_user_scheduled_date", columnList = "user_id,scheduled_date"),
                @Index(name = "idx_task_instances_user_due_datetime", columnList = "user_id,due_date_time"),
                @Index(name = "idx_task_instances_template", columnList = "template_id"),
                @Index(name = "idx_task_instances_rollover_from", columnList = "rolled_over_from_instance_id"),
                @Index(name = "idx_task_instances_rollover_to", columnList = "rolled_over_to_instance_id")
        }
)
@Getter
@Setter
public class TaskInstance extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    /**
     * Nullable for one-off manual inbox tasks.
     * Non-null for recurring spawned tasks.
     */
    @Column(name = "template_id")
    private UUID templateId;

    /**
     * Snapshot fields preserve historical truth
     * even if the template title/priority/category changes later.
     */
    @Column(name = "title_snapshot", nullable = false, length = 300)
    private String titleSnapshot;

    @Column(name = "description_snapshot", length = 4000)
    private String descriptionSnapshot;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 40)
    private TaskInstanceStatus status = TaskInstanceStatus.INBOX;

    /**
     * Used for PAUSE/RESUME and ARCHIVE/RESTORE.
     */
    @Enumerated(EnumType.STRING)
    @Column(name = "previous_status", length = 40)
    private TaskInstanceStatus previousStatus;

    @Enumerated(EnumType.STRING)
    @Column(name = "priority_snapshot", nullable = false, length = 40)
    private TaskPriority prioritySnapshot = TaskPriority.MEDIUM;

    @Column(name = "category_snapshot", length = 100)
    private String categorySnapshot;

    @Enumerated(EnumType.STRING)
    @Column(name = "source_type", nullable = false, length = 40)
    private TaskSourceType sourceType = TaskSourceType.MANUAL;

    /**
     * Original occurrence date.
     *
     * For recurring tasks, this represents the date generated from recurrence.
     * If rescheduled, occurrenceDate should remain stable;
     * scheduledDate changes.
     */
    @Column(name = "occurrence_date")
    private LocalDate occurrenceDate;

    /**
     * Current planned date after reschedule/rollover.
     */
    @Column(name = "scheduled_date")
    private LocalDate scheduledDate;

    /**
     * Current exact due date-time.
     */
    @Column(name = "due_date_time")
    private LocalDateTime dueDateTime;

    @Column(name = "linked_schedule_block_id_snapshot")
    private UUID linkedScheduleBlockIdSnapshot;

    @Column(name = "started_at")
    private Instant startedAt;

    @Column(name = "completed_at")
    private Instant completedAt;

    /**
     * User-local date this completion counts for.
     */
    @Column(name = "achieved_date")
    private LocalDate achievedDate;

    /**
     * Hide from Done view only.
     * History/timeline/analytics still keep the instance.
     */
    @Column(name = "done_cleared_at")
    private Instant doneClearedAt;

    @Column(name = "missed_at")
    private Instant missedAt;

    @Column(name = "skipped_at")
    private Instant skippedAt;

    @Column(name = "rolled_over_at")
    private Instant rolledOverAt;

    @Column(name = "rolled_over_from_instance_id")
    private UUID rolledOverFromInstanceId;

    @Column(name = "rolled_over_to_instance_id")
    private UUID rolledOverToInstanceId;

    @Column(name = "paused_at")
    private Instant pausedAt;

    @Column(name = "archived_at")
    private Instant archivedAt;

    @Column(name = "cancelled_at")
    private Instant cancelledAt;

    public boolean isFinalState() {
        return status != null && status.isFinalState();
    }

    public boolean isWorkable() {
        return status != null && status.isWorkable();
    }

    public boolean isCompleted() {
        return status == TaskInstanceStatus.COMPLETED;
    }

    public boolean isArchived() {
        return status == TaskInstanceStatus.ARCHIVED;
    }

    public boolean isPaused() {
        return status == TaskInstanceStatus.PAUSED;
    }

    public boolean isOverdue() {
        return status == TaskInstanceStatus.OVERDUE;
    }

    public boolean isMissed() {
        return status == TaskInstanceStatus.MISSED;
    }

    public boolean isSkipped() {
        return status == TaskInstanceStatus.SKIPPED;
    }

    public void rememberPreviousStatus() {
        if (this.status != null
                && this.status != TaskInstanceStatus.PAUSED
                && this.status != TaskInstanceStatus.ARCHIVED) {
            this.previousStatus = this.status;
        }
    }

    public TaskInstanceStatus restoreTargetStatus() {
        if (previousStatus != null) {
            return previousStatus;
        }

        if (scheduledDate == null) {
            return TaskInstanceStatus.INBOX;
        }

        return TaskInstanceStatus.SCHEDULED;
    }

    public void clearPreviousStatus() {
        this.previousStatus = null;
    }
}