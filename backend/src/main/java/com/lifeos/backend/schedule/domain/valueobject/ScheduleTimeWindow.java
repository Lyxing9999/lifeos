package com.lifeos.backend.schedule.domain.valueobject;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.Getter;
import lombok.Setter;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

/**
 * Represents one local schedule time window.
 *
 * Schedule is user-local by nature:
 * - Deep Work 09:00 - 11:00
 * - Class 13:00 - 15:00
 */
@Embeddable
@Getter
@Setter
public class ScheduleTimeWindow {

    @Column(name = "window_date")
    private LocalDate date;

    @Column(name = "window_start_time")
    private LocalTime startTime;

    @Column(name = "window_end_time")
    private LocalTime endTime;

    public ScheduleTimeWindow() {
    }

    public ScheduleTimeWindow(
            LocalDate date,
            LocalTime startTime,
            LocalTime endTime
    ) {
        this.date = date;
        this.startTime = startTime;
        this.endTime = endTime;
        validate();
    }

    public static ScheduleTimeWindow of(
            LocalDate date,
            LocalTime startTime,
            LocalTime endTime
    ) {
        return new ScheduleTimeWindow(date, startTime, endTime);
    }

    public LocalDateTime startDateTime() {
        if (date == null || startTime == null) {
            return null;
        }

        return date.atTime(startTime);
    }

    public LocalDateTime endDateTime() {
        if (date == null || endTime == null) {
            return null;
        }

        return date.atTime(endTime);
    }

    public long durationMinutes() {
        if (startTime == null || endTime == null) {
            return 0;
        }

        return Duration.between(startTime, endTime).toMinutes();
    }

    public boolean overlaps(ScheduleTimeWindow other) {
        if (other == null) {
            return false;
        }

        if (startDateTime() == null
                || endDateTime() == null
                || other.startDateTime() == null
                || other.endDateTime() == null) {
            return false;
        }

        return startDateTime().isBefore(other.endDateTime())
                && endDateTime().isAfter(other.startDateTime());
    }

    public boolean contains(LocalDateTime dateTime) {
        if (dateTime == null || startDateTime() == null || endDateTime() == null) {
            return false;
        }

        return !dateTime.isBefore(startDateTime())
                && dateTime.isBefore(endDateTime());
    }

    public boolean isBefore(LocalDateTime dateTime) {
        return endDateTime() != null
                && dateTime != null
                && endDateTime().isBefore(dateTime);
    }

    public boolean isAfter(LocalDateTime dateTime) {
        return startDateTime() != null
                && dateTime != null
                && startDateTime().isAfter(dateTime);
    }

    public void validate() {
        if (date == null) {
            throw new IllegalArgumentException("date is required");
        }

        if (startTime == null || endTime == null) {
            throw new IllegalArgumentException("startTime and endTime are required");
        }

        if (!startTime.isBefore(endTime)) {
            throw new IllegalArgumentException("startTime must be before endTime");
        }
    }
}