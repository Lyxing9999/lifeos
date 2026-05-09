package com.lifeos.backend.task.domain.valueobject;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Position of a task inside a timeline/day view.
 *
 * This is not the full timeline domain.
 * It is only a task-side projection hint.
 */
@Embeddable
@Getter
@Setter
public class TimelinePosition {

    @Column(name = "timeline_date")
    private LocalDate timelineDate;

    @Column(name = "timeline_start")
    private LocalDateTime startDateTime;

    @Column(name = "timeline_end")
    private LocalDateTime endDateTime;

    @Column(name = "timeline_sort_order")
    private Integer sortOrder;

    /**
     * Example:
     * TODAY, SCHEDULE, INBOX, DONE, OVERDUE
     */
    @Column(name = "timeline_lane", length = 80)
    private String lane;

    public TimelinePosition() {
    }

    public TimelinePosition(
            LocalDate timelineDate,
            LocalDateTime startDateTime,
            LocalDateTime endDateTime,
            Integer sortOrder,
            String lane
    ) {
        this.timelineDate = timelineDate;
        this.startDateTime = startDateTime;
        this.endDateTime = endDateTime;
        this.sortOrder = sortOrder;
        this.lane = normalizeLane(lane);
    }

    public static TimelinePosition inbox(Integer sortOrder) {
        return new TimelinePosition(
                null,
                null,
                null,
                sortOrder,
                "INBOX"
        );
    }

    public static TimelinePosition day(
            LocalDate date,
            Integer sortOrder,
            String lane
    ) {
        return new TimelinePosition(
                date,
                null,
                null,
                sortOrder,
                lane
        );
    }

    public static TimelinePosition block(
            LocalDateTime start,
            LocalDateTime end,
            Integer sortOrder,
            String lane
    ) {
        return new TimelinePosition(
                start == null ? null : start.toLocalDate(),
                start,
                end,
                sortOrder,
                lane
        );
    }

    public boolean hasTimeBlock() {
        return startDateTime != null || endDateTime != null;
    }

    public boolean isOnDate(LocalDate date) {
        return timelineDate != null && timelineDate.equals(date);
    }

    public void validate() {
        if (startDateTime != null && endDateTime != null && endDateTime.isBefore(startDateTime)) {
            throw new IllegalArgumentException("timeline endDateTime must be after startDateTime");
        }
    }

    private String normalizeLane(String raw) {
        if (raw == null || raw.isBlank()) {
            return null;
        }

        return raw.trim().toUpperCase();
    }
}