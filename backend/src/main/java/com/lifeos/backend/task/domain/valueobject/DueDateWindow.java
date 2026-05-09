package com.lifeos.backend.task.domain.valueobject;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Represents the planned date/time window of a task instance.
 *
 * scheduledDate = day-level planning.
 * dueDateTime = exact deadline/time.
 * durationMinutes = optional work block length.
 */
@Embeddable
@Getter
@Setter
public class DueDateWindow {

    @Column(name = "window_scheduled_date")
    private LocalDate scheduledDate;

    @Column(name = "window_due_date_time")
    private LocalDateTime dueDateTime;

    @Column(name = "window_duration_minutes")
    private Integer durationMinutes;

    public DueDateWindow() {
    }

    public DueDateWindow(
            LocalDate scheduledDate,
            LocalDateTime dueDateTime,
            Integer durationMinutes
    ) {
        this.scheduledDate = scheduledDate == null && dueDateTime != null
                ? dueDateTime.toLocalDate()
                : scheduledDate;

        this.dueDateTime = dueDateTime;
        this.durationMinutes = durationMinutes;
    }

    public static DueDateWindow inbox() {
        return new DueDateWindow(null, null, null);
    }

    public static DueDateWindow scheduledDate(LocalDate scheduledDate) {
        return new DueDateWindow(scheduledDate, null, null);
    }

    public static DueDateWindow exact(LocalDateTime dueDateTime) {
        return new DueDateWindow(
                dueDateTime == null ? null : dueDateTime.toLocalDate(),
                dueDateTime,
                null
        );
    }

    public static DueDateWindow block(
            LocalDateTime startDateTime,
            Integer durationMinutes
    ) {
        return new DueDateWindow(
                startDateTime == null ? null : startDateTime.toLocalDate(),
                startDateTime,
                durationMinutes
        );
    }

    public boolean isInbox() {
        return scheduledDate == null && dueDateTime == null;
    }

    public boolean hasExactTime() {
        return dueDateTime != null;
    }

    public LocalDate effectiveDate() {
        if (scheduledDate != null) {
            return scheduledDate;
        }

        if (dueDateTime != null) {
            return dueDateTime.toLocalDate();
        }

        return null;
    }

    public LocalDateTime startDateTime() {
        return dueDateTime;
    }

    public LocalDateTime endDateTime() {
        if (dueDateTime == null || durationMinutes == null || durationMinutes <= 0) {
            return null;
        }

        return dueDateTime.plusMinutes(durationMinutes);
    }

    public boolean isDueOn(LocalDate date) {
        LocalDate effective = effectiveDate();
        return effective != null && effective.equals(date);
    }

    public boolean isBefore(LocalDate date) {
        LocalDate effective = effectiveDate();
        return effective != null && date != null && effective.isBefore(date);
    }

    public boolean isAfter(LocalDate date) {
        LocalDate effective = effectiveDate();
        return effective != null && date != null && effective.isAfter(date);
    }

    public boolean isOverdueAt(LocalDate userToday, LocalDateTime userNow) {
        if (isInbox()) {
            return false;
        }

        if (dueDateTime != null && userNow != null) {
            return dueDateTime.isBefore(userNow);
        }

        LocalDate effective = effectiveDate();
        return effective != null && userToday != null && effective.isBefore(userToday);
    }

    public void validate() {
        if (durationMinutes != null && durationMinutes <= 0) {
            throw new IllegalArgumentException("durationMinutes must be positive");
        }
    }
}