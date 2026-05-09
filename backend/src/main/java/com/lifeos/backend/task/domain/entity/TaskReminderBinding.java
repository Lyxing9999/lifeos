package com.lifeos.backend.task.domain.entity;

import com.lifeos.backend.common.base.BaseEntity;
import com.lifeos.backend.task.domain.enums.ReminderType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Reminder config attached to a template or instance.
 *
 * Reminder intent belongs here.
 * Actual push delivery belongs to notification domain.
 */
@Entity
@Table(
        name = "task_reminder_bindings",
        indexes = {
                @Index(name = "idx_task_reminders_user_enabled", columnList = "user_id,enabled"),
                @Index(name = "idx_task_reminders_template", columnList = "template_id"),
                @Index(name = "idx_task_reminders_instance", columnList = "task_instance_id"),
                @Index(name = "idx_task_reminders_type", columnList = "reminder_type")
        }
)
@Getter
@Setter
public class TaskReminderBinding extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "template_id")
    private UUID templateId;

    @Column(name = "task_instance_id")
    private UUID taskInstanceId;

    @Enumerated(EnumType.STRING)
    @Column(name = "reminder_type", nullable = false, length = 60)
    private ReminderType reminderType = ReminderType.NONE;

    /**
     * For EXACT_TIME reminder.
     */
    @Column(name = "remind_at")
    private LocalDateTime remindAt;

    /**
     * For BEFORE_DUE_TIME.
     */
    @Column(name = "minutes_before_due")
    private Integer minutesBeforeDue;

    /**
     * Future place intelligence.
     */
    @Column(name = "place_id")
    private UUID placeId;

    /**
     * For schedule-linked reminder.
     */
    @Column(name = "schedule_block_id")
    private UUID scheduleBlockId;

    @Column(nullable = false)
    private Boolean enabled = true;

    @Column(name = "last_triggered_at")
    private Instant lastTriggeredAt;

    public boolean isEnabled() {
        return Boolean.TRUE.equals(enabled) && reminderType != ReminderType.NONE;
    }

    public void disable() {
        this.enabled = false;
    }

    public void enable() {
        this.enabled = true;
    }

    public void markTriggered() {
        this.lastTriggeredAt = Instant.now();
    }
}