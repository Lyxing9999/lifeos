package com.lifeos.backend.schedule.domain.service;

import com.lifeos.backend.schedule.domain.entity.ScheduleOccurrence;
import com.lifeos.backend.schedule.domain.entity.ScheduleTemplate;
import com.lifeos.backend.schedule.domain.valueobject.ScheduleTimeWindow;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Component
public class ScheduleTimeWindowService {

    public ScheduleTimeWindow windowForTemplate(
            ScheduleTemplate template,
            LocalDate occurrenceDate
    ) {
        if (template == null) {
            throw new IllegalArgumentException("ScheduleTemplate is required");
        }

        if (occurrenceDate == null) {
            throw new IllegalArgumentException("occurrenceDate is required");
        }

        return ScheduleTimeWindow.of(
                occurrenceDate,
                template.getStartTime(),
                template.getEndTime()
        );
    }

    public ScheduleTimeWindow windowForOccurrence(
            ScheduleOccurrence occurrence
    ) {
        if (occurrence == null) {
            throw new IllegalArgumentException("ScheduleOccurrence is required");
        }

        if (occurrence.getStartDateTime() == null || occurrence.getEndDateTime() == null) {
            throw new IllegalArgumentException("occurrence start/end datetime is required");
        }

        return ScheduleTimeWindow.of(
                occurrence.getScheduledDate(),
                occurrence.getStartDateTime().toLocalTime(),
                occurrence.getEndDateTime().toLocalTime()
        );
    }

    public LocalDateTime startDateTime(
            ScheduleTemplate template,
            LocalDate occurrenceDate
    ) {
        return windowForTemplate(template, occurrenceDate).startDateTime();
    }

    public LocalDateTime endDateTime(
            ScheduleTemplate template,
            LocalDate occurrenceDate
    ) {
        return windowForTemplate(template, occurrenceDate).endDateTime();
    }

    public boolean isActiveAt(
            ScheduleOccurrence occurrence,
            LocalDateTime nowLocalDateTime
    ) {
        if (occurrence == null || nowLocalDateTime == null) {
            return false;
        }

        if (occurrence.getStartDateTime() == null || occurrence.getEndDateTime() == null) {
            return false;
        }

        return !nowLocalDateTime.isBefore(occurrence.getStartDateTime())
                && nowLocalDateTime.isBefore(occurrence.getEndDateTime());
    }

    public boolean isExpiredAt(
            ScheduleOccurrence occurrence,
            LocalDateTime nowLocalDateTime
    ) {
        if (occurrence == null || nowLocalDateTime == null) {
            return false;
        }

        return occurrence.getEndDateTime() != null
                && occurrence.getEndDateTime().isBefore(nowLocalDateTime);
    }

    public void validateTemplateWindow(ScheduleTemplate template) {
        if (template == null) {
            throw new IllegalArgumentException("ScheduleTemplate is required");
        }

        template.validateTimeWindow();
    }

    public void validateOccurrenceWindow(ScheduleOccurrence occurrence) {
        if (occurrence == null) {
            throw new IllegalArgumentException("ScheduleOccurrence is required");
        }

        occurrence.validateTimeWindow();
    }
}