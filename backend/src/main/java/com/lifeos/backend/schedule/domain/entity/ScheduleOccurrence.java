package com.lifeos.backend.schedule.domain.entity;

import com.lifeos.backend.common.base.BaseEntity;
import com.lifeos.backend.schedule.domain.enums.ScheduleBlockType;
import com.lifeos.backend.schedule.domain.enums.ScheduleOccurrenceStatus;
import com.lifeos.backend.schedule.domain.enums.ScheduleSourceType;
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
 * ScheduleOccurrence = one real planned time block.
 *
 * Example:
 * "Deep Work on 2026-05-08 from 9:00 to 11:00"
 *
 * This is what Timeline should read.
 * This protects history when ScheduleTemplate changes later.
 */
@Entity
@Table(
        name = "schedule_occurrences",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_schedule_occurrence_template_date",
                        columnNames = {"template_id", "occurrence_date"}
                )
        },
        indexes = {
                @Index(name = "idx_schedule_occurrences_user_date", columnList = "user_id,occurrence_date"),
                @Index(name = "idx_schedule_occurrences_user_status", columnList = "user_id,status"),
                @Index(name = "idx_schedule_occurrences_start_end", columnList = "user_id,start_date_time,end_date_time"),
                @Index(name = "idx_schedule_occurrences_template", columnList = "template_id"),
                @Index(name = "idx_schedule_occurrences_source", columnList = "source_type")
        }
)
@Getter
@Setter
public class ScheduleOccurrence extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    /**
     * Nullable for manual one-off schedule blocks.
     * Non-null for spawned occurrences.
     */
    @Column(name = "template_id")
    private UUID templateId;

    /**
     * Snapshot fields preserve historical truth even if template changes later.
     */
    @Column(name = "title_snapshot", nullable = false, length = 200)
    private String titleSnapshot;

    @Enumerated(EnumType.STRING)
    @Column(name = "type_snapshot", nullable = false, length = 50)
    private ScheduleBlockType typeSnapshot = ScheduleBlockType.OTHER;

    @Column(name = "description_snapshot", length = 1000)
    private String descriptionSnapshot;

    /**
     * Original recurrence date.
     * If rescheduled, this stays as the original occurrence date.
     */
    @Column(name = "occurrence_date")
    private LocalDate occurrenceDate;

    /**
     * Current planned date.
     * Usually same as occurrenceDate, but can differ after reschedule.
     */
    @Column(name = "scheduled_date", nullable = false)
    private LocalDate scheduledDate;

    @Column(name = "start_date_time", nullable = false)
    private LocalDateTime startDateTime;

    @Column(name = "end_date_time", nullable = false)
    private LocalDateTime endDateTime;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    private ScheduleOccurrenceStatus status = ScheduleOccurrenceStatus.PLANNED;

    /**
     * Used for archive/restore-like behavior if needed later.
     * Schedule does not need a heavy state machine now.
     */
    @Enumerated(EnumType.STRING)
    @Column(name = "previous_status", length = 50)
    private ScheduleOccurrenceStatus previousStatus;

    @Enumerated(EnumType.STRING)
    @Column(name = "source_type", nullable = false, length = 50)
    private ScheduleSourceType sourceType = ScheduleSourceType.MANUAL;

    /**
     * Optional link to a task instance/template.
     * This is only a reference. Schedule does not own task completion.
     */
    @Column(name = "linked_task_instance_id")
    private UUID linkedTaskInstanceId;

    @Column(name = "linked_task_template_id")
    private UUID linkedTaskTemplateId;

    /**
     * Reschedule relationship.
     *
     * Old occurrence -> RESCHEDULED
     * New occurrence -> PLANNED with rescheduledFromOccurrenceId
     */
    @Column(name = "rescheduled_from_occurrence_id")
    private UUID rescheduledFromOccurrenceId;

    @Column(name = "rescheduled_to_occurrence_id")
    private UUID rescheduledToOccurrenceId;

    @Column(name = "activated_at")
    private Instant activatedAt;

    @Column(name = "expired_at")
    private Instant expiredAt;

    @Column(name = "cancelled_at")
    private Instant cancelledAt;

    @Column(name = "skipped_at")
    private Instant skippedAt;

    @Column(name = "rescheduled_at")
    private Instant rescheduledAt;

    public boolean isOpen() {
        return status != null && status.isOpen();
    }

    public boolean isFinalState() {
        return status != null && status.isFinalState();
    }

    public boolean isPlanned() {
        return status == ScheduleOccurrenceStatus.PLANNED;
    }

    public boolean isActive() {
        return status == ScheduleOccurrenceStatus.ACTIVE;
    }

    public boolean isExpired() {
        return status == ScheduleOccurrenceStatus.EXPIRED;
    }

    public boolean isCancelled() {
        return status == ScheduleOccurrenceStatus.CANCELLED;
    }

    public boolean isSkipped() {
        return status == ScheduleOccurrenceStatus.SKIPPED;
    }

    public boolean isRescheduled() {
        return status == ScheduleOccurrenceStatus.RESCHEDULED;
    }

    public boolean overlaps(LocalDateTime start, LocalDateTime end) {
        if (start == null || end == null || startDateTime == null || endDateTime == null) {
            return false;
        }

        return startDateTime.isBefore(end) && endDateTime.isAfter(start);
    }

    public void activate(Instant now) {
        this.status = ScheduleOccurrenceStatus.ACTIVE;
        this.activatedAt = now == null ? Instant.now() : now;
    }

    public void expire(Instant now) {
        this.status = ScheduleOccurrenceStatus.EXPIRED;
        this.expiredAt = now == null ? Instant.now() : now;
    }

    public void cancel(Instant now) {
        this.status = ScheduleOccurrenceStatus.CANCELLED;
        this.cancelledAt = now == null ? Instant.now() : now;
    }

    public void skip(Instant now) {
        this.status = ScheduleOccurrenceStatus.SKIPPED;
        this.skippedAt = now == null ? Instant.now() : now;
    }

    public void markRescheduled(Instant now) {
        this.status = ScheduleOccurrenceStatus.RESCHEDULED;
        this.rescheduledAt = now == null ? Instant.now() : now;
    }

    public void validateTimeWindow() {
        if (startDateTime == null || endDateTime == null) {
            throw new IllegalArgumentException("startDateTime and endDateTime are required");
        }

        if (!startDateTime.isBefore(endDateTime)) {
            throw new IllegalArgumentException("startDateTime must be before endDateTime");
        }
    }
}