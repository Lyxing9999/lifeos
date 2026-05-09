package com.lifeos.backend.task.domain.entity;

import com.lifeos.backend.common.base.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.util.UUID;

/**
 * Link between task domain and notification domain.
 *
 * Task owns the intent to remind.
 * Notification domain owns delivery.
 */
@Entity
@Table(
        name = "task_notification_bindings",
        indexes = {
                @Index(name = "idx_task_notifications_user_enabled", columnList = "user_id,enabled"),
                @Index(name = "idx_task_notifications_template", columnList = "template_id"),
                @Index(name = "idx_task_notifications_instance", columnList = "task_instance_id"),
                @Index(name = "idx_task_notifications_event", columnList = "notification_event_id")
        }
)
@Getter
@Setter
public class TaskNotificationBinding extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "template_id")
    private UUID templateId;

    @Column(name = "task_instance_id")
    private UUID taskInstanceId;

    /**
     * ID from notification domain.
     */
    @Column(name = "notification_event_id")
    private UUID notificationEventId;

    /**
     * Example:
     * PUSH, EMAIL, TELEGRAM, IN_APP
     *
     * Keep as String now to avoid coupling too early.
     */
    @Column(length = 40)
    private String channel;

    @Column(nullable = false)
    private Boolean enabled = true;

    @Column(name = "last_sent_at")
    private Instant lastSentAt;

    @Column(name = "failure_count")
    private Integer failureCount = 0;

    public boolean isEnabled() {
        return Boolean.TRUE.equals(enabled);
    }

    public void disable() {
        this.enabled = false;
    }

    public void enable() {
        this.enabled = true;
    }

    public void markSent() {
        this.lastSentAt = Instant.now();
        this.failureCount = 0;
    }

    public void markFailed() {
        if (this.failureCount == null) {
            this.failureCount = 0;
        }

        this.failureCount++;
    }
}