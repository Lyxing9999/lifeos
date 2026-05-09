package com.lifeos.backend.task.domain.valueobject;

import com.lifeos.backend.task.domain.enums.ReminderType;
import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Reminder value object.
 *
 * Reminder describes reminder intent.
 * Notification delivery belongs to notification domain.
 */
@Embeddable
@Getter
@Setter
public class Reminder {

    @Enumerated(EnumType.STRING)
    @Column(name = "reminder_type", nullable = false, length = 60)
    private ReminderType type = ReminderType.NONE;

    /**
     * Used for EXACT_TIME.
     */
    @Column(name = "reminder_at")
    private LocalDateTime remindAt;

    /**
     * Used for BEFORE_DUE_TIME.
     */
    @Column(name = "reminder_minutes_before_due")
    private Integer minutesBeforeDue;

    /**
     * Future place-aware reminder.
     */
    @Column(name = "reminder_place_id")
    private UUID placeId;

    /**
     * Used for SCHEDULE_BASED reminder.
     */
    @Column(name = "reminder_schedule_block_id")
    private UUID scheduleBlockId;

    @Column(name = "reminder_enabled", nullable = false)
    private Boolean enabled = false;

    public Reminder() {
    }

    public Reminder(
            ReminderType type,
            LocalDateTime remindAt,
            Integer minutesBeforeDue,
            UUID placeId,
            UUID scheduleBlockId,
            Boolean enabled
    ) {
        this.type = type == null ? ReminderType.NONE : type;
        this.remindAt = remindAt;
        this.minutesBeforeDue = minutesBeforeDue;
        this.placeId = placeId;
        this.scheduleBlockId = scheduleBlockId;
        this.enabled = enabled != null && enabled;
    }

    public static Reminder none() {
        return new Reminder(
                ReminderType.NONE,
                null,
                null,
                null,
                null,
                false
        );
    }

    public static Reminder exactTime(LocalDateTime remindAt) {
        return new Reminder(
                ReminderType.EXACT_TIME,
                remindAt,
                null,
                null,
                null,
                true
        );
    }

    public static Reminder beforeDueTime(Integer minutesBeforeDue) {
        return new Reminder(
                ReminderType.BEFORE_DUE_TIME,
                null,
                minutesBeforeDue,
                null,
                null,
                true
        );
    }

    public static Reminder startOfDay() {
        return new Reminder(
                ReminderType.START_OF_DAY,
                null,
                null,
                null,
                null,
                true
        );
    }

    public static Reminder endOfDay() {
        return new Reminder(
                ReminderType.END_OF_DAY,
                null,
                null,
                null,
                null,
                true
        );
    }

    public boolean isEnabled() {
        return Boolean.TRUE.equals(enabled)
                && type != null
                && type.isEnabled();
    }

    public void disable() {
        this.enabled = false;
        this.type = ReminderType.NONE;
        this.remindAt = null;
        this.minutesBeforeDue = null;
        this.placeId = null;
        this.scheduleBlockId = null;
    }

    public void validate() {
        if (type == null) {
            this.type = ReminderType.NONE;
        }

        if (type == ReminderType.NONE) {
            return;
        }

        if (type == ReminderType.EXACT_TIME && remindAt == null) {
            throw new IllegalArgumentException("remindAt is required for EXACT_TIME reminder");
        }

        if (type == ReminderType.BEFORE_DUE_TIME
                && (minutesBeforeDue == null || minutesBeforeDue < 0)) {
            throw new IllegalArgumentException("minutesBeforeDue must be zero or positive");
        }

        if (type == ReminderType.LOCATION_BASED && placeId == null) {
            throw new IllegalArgumentException("placeId is required for LOCATION_BASED reminder");
        }

        if (type == ReminderType.SCHEDULE_BASED && scheduleBlockId == null) {
            throw new IllegalArgumentException("scheduleBlockId is required for SCHEDULE_BASED reminder");
        }
    }
}