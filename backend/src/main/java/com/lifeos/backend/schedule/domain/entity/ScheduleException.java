package com.lifeos.backend.schedule.domain.entity;

import com.lifeos.backend.common.base.BaseEntity;
import com.lifeos.backend.schedule.domain.enums.ScheduleExceptionType;
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
 * ScheduleException = one-occurrence override.
 *
 * Example:
 * Template: Deep Work every weekday 9:00-11:00
 * Exception:
 * - skip 2026-05-08
 * - move 2026-05-08 to 14:00-16:00
 * - cancel 2026-05-08
 */
@Entity
@Table(
        name = "schedule_exceptions",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_schedule_exception_template_date",
                        columnNames = {"template_id", "occurrence_date"}
                )
        },
        indexes = {
                @Index(name = "idx_schedule_exceptions_user", columnList = "user_id"),
                @Index(name = "idx_schedule_exceptions_template", columnList = "template_id"),
                @Index(name = "idx_schedule_exceptions_type", columnList = "type")
        }
)
@Getter
@Setter
public class ScheduleException extends BaseEntity {

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
    @Column(nullable = false, length = 50)
    private ScheduleExceptionType type;

    /**
     * Optional existing occurrence affected by this exception.
     */
    @Column(name = "schedule_occurrence_id")
    private UUID scheduleOccurrenceId;

    /**
     * Used when type = RESCHEDULED.
     */
    @Column(name = "rescheduled_date")
    private LocalDate rescheduledDate;

    @Column(name = "rescheduled_start_date_time")
    private LocalDateTime rescheduledStartDateTime;

    @Column(name = "rescheduled_end_date_time")
    private LocalDateTime rescheduledEndDateTime;

    @Column(length = 1000)
    private String reason;

    @Column(name = "applied_at")
    private Instant appliedAt;

    public boolean isSkipped() {
        return type == ScheduleExceptionType.SKIPPED;
    }

    public boolean isRescheduled() {
        return type == ScheduleExceptionType.RESCHEDULED;
    }

    public boolean isCancelled() {
        return type == ScheduleExceptionType.CANCELLED;
    }

    public boolean preventsOriginalSpawn() {
        return type != null && type.preventsOriginalSpawn();
    }

    public void markApplied() {
        this.appliedAt = Instant.now();
    }

    public void validateRescheduleWindow() {
        if (type != ScheduleExceptionType.RESCHEDULED) {
            return;
        }

        if (rescheduledStartDateTime == null || rescheduledEndDateTime == null) {
            throw new IllegalArgumentException(
                    "rescheduledStartDateTime and rescheduledEndDateTime are required"
            );
        }

        if (!rescheduledStartDateTime.isBefore(rescheduledEndDateTime)) {
            throw new IllegalArgumentException(
                    "rescheduledStartDateTime must be before rescheduledEndDateTime"
            );
        }

        if (rescheduledDate == null) {
            rescheduledDate = rescheduledStartDateTime.toLocalDate();
        }
    }
}