package com.lifeos.backend.schedule.domain.service;

import com.lifeos.backend.schedule.domain.entity.ScheduleOccurrence;
import com.lifeos.backend.schedule.domain.valueobject.ScheduleTimeWindow;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Component
public class ScheduleOverlapDetector {

    public boolean overlaps(
            ScheduleOccurrence occurrence,
            LocalDateTime startDateTime,
            LocalDateTime endDateTime
    ) {
        if (occurrence == null || startDateTime == null || endDateTime == null) {
            return false;
        }

        if (!startDateTime.isBefore(endDateTime)) {
            throw new IllegalArgumentException("startDateTime must be before endDateTime");
        }

        return occurrence.getStartDateTime().isBefore(endDateTime)
                && occurrence.getEndDateTime().isAfter(startDateTime);
    }

    public boolean overlaps(
            ScheduleOccurrence occurrence,
            ScheduleTimeWindow window
    ) {
        if (window == null) {
            return false;
        }

        return overlaps(
                occurrence,
                window.startDateTime(),
                window.endDateTime()
        );
    }

    public List<ScheduleOccurrence> findOverlaps(
            List<ScheduleOccurrence> existingOccurrences,
            LocalDateTime startDateTime,
            LocalDateTime endDateTime
    ) {
        if (existingOccurrences == null || existingOccurrences.isEmpty()) {
            return List.of();
        }

        return existingOccurrences.stream()
                .filter(occurrence -> overlaps(occurrence, startDateTime, endDateTime))
                .toList();
    }

    public List<ScheduleOccurrence> findOverlapsExcluding(
            List<ScheduleOccurrence> existingOccurrences,
            UUID excludedOccurrenceId,
            LocalDateTime startDateTime,
            LocalDateTime endDateTime
    ) {
        if (existingOccurrences == null || existingOccurrences.isEmpty()) {
            return List.of();
        }

        return existingOccurrences.stream()
                .filter(occurrence -> excludedOccurrenceId == null
                        || !excludedOccurrenceId.equals(occurrence.getId()))
                .filter(occurrence -> overlaps(occurrence, startDateTime, endDateTime))
                .toList();
    }

    public boolean hasOverlap(
            List<ScheduleOccurrence> existingOccurrences,
            LocalDateTime startDateTime,
            LocalDateTime endDateTime
    ) {
        return !findOverlaps(existingOccurrences, startDateTime, endDateTime).isEmpty();
    }
}