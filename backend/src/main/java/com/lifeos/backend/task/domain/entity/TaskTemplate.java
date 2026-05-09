package com.lifeos.backend.task.domain.entity;

import com.lifeos.backend.common.base.BaseEntity;
import com.lifeos.backend.task.domain.enums.MissedPolicy;
import com.lifeos.backend.task.domain.enums.OverduePolicy;
import com.lifeos.backend.task.domain.enums.RolloverPolicy;
import com.lifeos.backend.task.domain.enums.TaskPriority;
import com.lifeos.backend.task.domain.enums.TaskRecurrenceType;
import com.lifeos.backend.task.domain.enums.TaskTemplateStatus;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

/**
 * TaskTemplate = blueprint / intent.
 *
 * Example:
 * - "Study English"
 * - repeats every day
 * - priority HIGH
 * - default due time 20:00
 *
 * Important:
 * Template should NOT become completed.
 * Completion belongs to TaskInstance.
 */
@Entity
@Table(
        name = "task_templates",
        indexes = {
                @Index(name = "idx_task_templates_user_status", columnList = "user_id,status"),
                @Index(name = "idx_task_templates_user_priority", columnList = "user_id,priority"),
                @Index(name = "idx_task_templates_user_recurrence", columnList = "user_id,recurrence_type"),
                @Index(name = "idx_task_templates_user_archived", columnList = "user_id,archived"),
                @Index(name = "idx_task_templates_user_paused", columnList = "user_id,paused")
        }
)
@Getter
@Setter
public class TaskTemplate extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(nullable = false, length = 300)
    private String title;

    @Column(length = 4000)
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 40)
    private TaskTemplateStatus status = TaskTemplateStatus.ACTIVE;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 40)
    private TaskPriority priority = TaskPriority.MEDIUM;

    @Column(length = 100)
    private String category;

    /**
     * Recurrence blueprint.
     *
     * For now this is stored directly on the template.
     * Later you can move these fields into an @Embedded RecurrenceRule value object.
     */
    @Enumerated(EnumType.STRING)
    @Column(name = "recurrence_type", nullable = false, length = 40)
    private TaskRecurrenceType recurrenceType = TaskRecurrenceType.NONE;

    @Column(name = "recurrence_start_date")
    private LocalDate recurrenceStartDate;

    @Column(name = "recurrence_end_date")
    private LocalDate recurrenceEndDate;

    /**
     * Comma-separated days for CUSTOM_WEEKLY.
     *
     * Example:
     * MONDAY,WEDNESDAY,FRIDAY
     */
    @Column(name = "recurrence_days_of_week", length = 200)
    private String recurrenceDaysOfWeek;

    /**
     * Default planned day/time behavior for generated instances.
     */
    @Column(name = "default_due_time")
    private LocalTime defaultDueTime;

    @Column(name = "default_duration_minutes")
    private Integer defaultDurationMinutes;

    @Column(name = "linked_schedule_block_id")
    private UUID linkedScheduleBlockId;

    /**
     * Behavior policies for automation engines.
     */
    @Enumerated(EnumType.STRING)
    @Column(name = "overdue_policy", nullable = false, length = 60)
    private OverduePolicy overduePolicy = OverduePolicy.OVERDUE_AT_END_OF_DAY;

    @Enumerated(EnumType.STRING)
    @Column(name = "rollover_policy", nullable = false, length = 60)
    private RolloverPolicy rolloverPolicy = RolloverPolicy.KEEP_OVERDUE;

    @Enumerated(EnumType.STRING)
    @Column(name = "missed_policy", nullable = false, length = 60)
    private MissedPolicy missedPolicy = MissedPolicy.NEVER_MISS;

    @Column(nullable = false)
    private Boolean archived = false;

    @Column(name = "archived_at")
    private Instant archivedAt;

    @Column(nullable = false)
    private Boolean paused = false;

    @Column(name = "paused_at")
    private Instant pausedAt;

    public boolean isActiveTemplate() {
        return status == TaskTemplateStatus.ACTIVE
                && !isArchived()
                && !isPaused();
    }

    public boolean isRecurring() {
        return recurrenceType != null && recurrenceType != TaskRecurrenceType.NONE;
    }

    public boolean isArchived() {
        return Boolean.TRUE.equals(archived) || status == TaskTemplateStatus.ARCHIVED;
    }

    public boolean isPaused() {
        return Boolean.TRUE.equals(paused) || status == TaskTemplateStatus.PAUSED;
    }

    public void pause() {
        this.paused = true;
        this.pausedAt = Instant.now();
        this.status = TaskTemplateStatus.PAUSED;
    }

    public void resume() {
        this.paused = false;
        this.pausedAt = null;
        this.status = TaskTemplateStatus.ACTIVE;
    }

    public void archive() {
        this.archived = true;
        this.archivedAt = Instant.now();
        this.status = TaskTemplateStatus.ARCHIVED;
    }

    public void restore() {
        this.archived = false;
        this.archivedAt = null;
        this.status = TaskTemplateStatus.ACTIVE;
    }
}