package com.lifeos.backend.schedule.domain.entity;

import com.lifeos.backend.common.base.BaseEntity;
import com.lifeos.backend.schedule.domain.enums.ScheduleBlockType;
import com.lifeos.backend.schedule.domain.enums.ScheduleRecurrenceType;
import com.lifeos.backend.schedule.domain.enums.ScheduleTemplateStatus;
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
 * ScheduleTemplate = recurring/future planned time blueprint.
 *
 * Example:
 * "Deep Work every weekday from 9:00 to 11:00"
 *
 * This is NOT one real time block.
 * Real blocks are ScheduleOccurrence.
 */
@Entity
@Table(
        name = "schedule_templates",
        indexes = {
                @Index(name = "idx_schedule_templates_user_status", columnList = "user_id,status"),
                @Index(name = "idx_schedule_templates_user_recurrence", columnList = "user_id,recurrence_type"),
                @Index(name = "idx_schedule_templates_user_type", columnList = "user_id,type")
        }
)
@Getter
@Setter
public class ScheduleTemplate extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(nullable = false, length = 200)
    private String title;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    private ScheduleBlockType type = ScheduleBlockType.OTHER;

    @Column(length = 1000)
    private String description;

    /**
     * Local start time for spawned occurrences.
     */
    @Column(name = "start_time", nullable = false)
    private LocalTime startTime;

    /**
     * Local end time for spawned occurrences.
     */
    @Column(name = "end_time", nullable = false)
    private LocalTime endTime;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    private ScheduleTemplateStatus status = ScheduleTemplateStatus.ACTIVE;

    @Enumerated(EnumType.STRING)
    @Column(name = "recurrence_type", nullable = false, length = 50)
    private ScheduleRecurrenceType recurrenceType = ScheduleRecurrenceType.NONE;

    /**
     * Used by CUSTOM_WEEKLY.
     *
     * Example:
     * MONDAY,WEDNESDAY,FRIDAY
     */
    @Column(name = "recurrence_days_of_week", length = 120)
    private String recurrenceDaysOfWeek;

    /**
     * For NONE recurrence, this is the only occurrence date.
     * For recurring schedules, this is the first valid date.
     */
    @Column(name = "recurrence_start_date", nullable = false)
    private LocalDate recurrenceStartDate;

    @Column(name = "recurrence_end_date")
    private LocalDate recurrenceEndDate;

    /**
     * Optional color key for UI.
     * Keep as String now; do not couple to UI enum too early.
     */
    @Column(name = "color_key", length = 50)
    private String colorKey;

    /**
     * Optional external calendar reference.
     * Useful later for Google Calendar / school calendar sync.
     */
    @Column(name = "external_calendar_id")
    private UUID externalCalendarId;

    @Column(name = "archived_at")
    private Instant archivedAt;

    @Column(name = "paused_at")
    private Instant pausedAt;

    public boolean isActiveTemplate() {
        return status == ScheduleTemplateStatus.ACTIVE;
    }

    public boolean isPaused() {
        return status == ScheduleTemplateStatus.PAUSED;
    }

    public boolean isArchived() {
        return status == ScheduleTemplateStatus.ARCHIVED;
    }

    public boolean canSpawnOccurrences() {
        return status != null && status.canSpawnOccurrences();
    }

    public boolean isRecurring() {
        return recurrenceType != null && recurrenceType.isRecurring();
    }

    public boolean isOneTime() {
        return recurrenceType == ScheduleRecurrenceType.NONE;
    }

    public void pause() {
        this.status = ScheduleTemplateStatus.PAUSED;
        this.pausedAt = Instant.now();
    }

    public void resume() {
        this.status = ScheduleTemplateStatus.ACTIVE;
        this.pausedAt = null;
    }

    public void archive() {
        this.status = ScheduleTemplateStatus.ARCHIVED;
        this.archivedAt = Instant.now();
    }

    public void restore() {
        this.status = ScheduleTemplateStatus.ACTIVE;
        this.archivedAt = null;
    }

    public void validateTimeWindow() {
        if (startTime == null || endTime == null) {
            throw new IllegalArgumentException("startTime and endTime are required");
        }

        if (!startTime.isBefore(endTime)) {
            throw new IllegalArgumentException("startTime must be before endTime");
        }
    }
}