package com.lifeos.backend.schedule.domain.repository;

import com.lifeos.backend.schedule.domain.entity.ScheduleOccurrence;
import com.lifeos.backend.schedule.domain.enums.ScheduleOccurrenceStatus;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ScheduleOccurrenceRepository {

    ScheduleOccurrence save(ScheduleOccurrence occurrence);

    List<ScheduleOccurrence> saveAll(List<ScheduleOccurrence> occurrences);

    Optional<ScheduleOccurrence> findById(UUID occurrenceId);

    Optional<ScheduleOccurrence> findByIdForUser(UUID userId, UUID occurrenceId);

    Optional<ScheduleOccurrence> findByTemplateIdAndOccurrenceDate(
            UUID templateId,
            LocalDate occurrenceDate
    );

    boolean existsByTemplateIdAndOccurrenceDate(
            UUID templateId,
            LocalDate occurrenceDate
    );

    List<ScheduleOccurrence> findByUserIdAndOccurrenceDate(
            UUID userId,
            LocalDate occurrenceDate
    );

    List<ScheduleOccurrence> findByUserIdAndScheduledDate(
            UUID userId,
            LocalDate scheduledDate
    );

    List<ScheduleOccurrence> findByUserIdAndScheduledDateBetween(
            UUID userId,
            LocalDate startDate,
            LocalDate endDate
    );

    List<ScheduleOccurrence> findByUserIdAndStatus(
            UUID userId,
            ScheduleOccurrenceStatus status
    );

    /**
     * Used by overlap detection.
     */
    List<ScheduleOccurrence> findOverlapping(
            UUID userId,
            LocalDateTime startDateTime,
            LocalDateTime endDateTime
    );

    /**
     * Used by ScheduleExpirationPolicy / worker.
     */
    List<ScheduleOccurrence> findOpenOccurrencesBefore(
            UUID userId,
            LocalDateTime nowLocalDateTime,
            List<ScheduleOccurrenceStatus> statuses
    );

    /**
     * Used to activate occurrences whose time window contains "now".
     */
    List<ScheduleOccurrence> findOccurrencesActiveAt(
            UUID userId,
            LocalDateTime nowLocalDateTime,
            List<ScheduleOccurrenceStatus> statuses
    );

    List<ScheduleOccurrence> findByRescheduledFromOccurrenceId(UUID sourceOccurrenceId);

    List<ScheduleOccurrence> findByRescheduledToOccurrenceId(UUID targetOccurrenceId);

    void deleteById(UUID occurrenceId);
}