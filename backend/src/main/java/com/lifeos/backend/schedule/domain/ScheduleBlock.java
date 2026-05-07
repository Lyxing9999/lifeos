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
                // Highly optimized index for our new main query
                @Index(name = "idx_schedule_blocks_user_archived", columnList = "userId, archived")
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

    @Column(length = 120)
    private String recurrenceDaysOfWeek;

    @Column(nullable = false)
    private LocalDate recurrenceStartDate;

    private LocalDate recurrenceEndDate;

    @Column(nullable = false)
    private Boolean active = true;

    // THE ARCHIVE FLAG
    @Column(name = "archived", nullable = false)
    private boolean archived = false;

    public void activate() { this.active = true; }
    public void deactivate() { this.active = false; }
    public boolean isActiveBlock() { return Boolean.TRUE.equals(active); }
    public boolean isArchived() { return archived; }
    public void setArchived(boolean archived) { this.archived = archived; }
}