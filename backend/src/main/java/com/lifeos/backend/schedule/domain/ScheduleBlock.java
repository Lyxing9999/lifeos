package com.lifeos.backend.schedule.domain;

import com.lifeos.backend.common.base.BaseEntity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

@Entity
@Table(
        name = "schedule_blocks",
        indexes = {
                @Index(name = "idx_schedule_blocks_user", columnList = "userId"),
                @Index(name = "idx_schedule_blocks_user_active", columnList = "userId,active")
        }
)
@Getter
@Setter
public class ScheduleBlock extends BaseEntity {

    @Column(nullable = false)
    private UUID userId;

    @Column(nullable = false, length = 200)
    private String title;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ScheduleBlockType type = ScheduleBlockType.OTHER;

    @Column(length = 1000)
    private String description;

    @Column(nullable = false)
    private LocalTime startTime;

    @Column(nullable = false)
    private LocalTime endTime;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ScheduleRecurrenceType recurrenceType = ScheduleRecurrenceType.NONE;

    /**
     * For CUSTOM_WEEKLY.
     * Example: MONDAY,WEDNESDAY,FRIDAY
     */
    @Column(length = 120)
    private String recurrenceDaysOfWeek;

    /**
     * First date when recurrence starts being valid.
     */
    @Column(nullable = false)
    private LocalDate recurrenceStartDate;

    /**
     * Optional final valid date.
     */
    private LocalDate recurrenceEndDate;

    @Column(nullable = false)
    private Boolean active = true;

    public boolean isAllDayInvalid() {
        return endTime != null && startTime != null && !endTime.isAfter(startTime);
    }
}