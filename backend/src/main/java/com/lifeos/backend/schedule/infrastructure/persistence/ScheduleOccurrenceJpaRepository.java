package com.lifeos.backend.schedule.infrastructure.persistence;

import com.lifeos.backend.schedule.domain.entity.ScheduleOccurrence;
import com.lifeos.backend.schedule.domain.enums.ScheduleOccurrenceStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ScheduleOccurrenceJpaRepository
        extends JpaRepository<ScheduleOccurrence, UUID> {

    Optional<ScheduleOccurrence> findByIdAndUserId(UUID id, UUID userId);

    Optional<ScheduleOccurrence> findByTemplateIdAndOccurrenceDate(
            UUID templateId,
            LocalDate occurrenceDate
    );

    boolean existsByTemplateIdAndOccurrenceDate(
            UUID templateId,
            LocalDate occurrenceDate
    );

    List<ScheduleOccurrence> findByUserIdAndOccurrenceDateOrderByStartDateTimeAsc(
            UUID userId,
            LocalDate occurrenceDate
    );

    List<ScheduleOccurrence> findByUserIdAndScheduledDateOrderByStartDateTimeAsc(
            UUID userId,
            LocalDate scheduledDate
    );

    List<ScheduleOccurrence> findByUserIdAndScheduledDateBetweenOrderByStartDateTimeAsc(
            UUID userId,
            LocalDate startDate,
            LocalDate endDate
    );

    List<ScheduleOccurrence> findByUserIdAndStatusOrderByStartDateTimeAsc(
            UUID userId,
            ScheduleOccurrenceStatus status
    );

    List<ScheduleOccurrence> findByRescheduledFromOccurrenceId(UUID rescheduledFromOccurrenceId);

    List<ScheduleOccurrence> findByRescheduledToOccurrenceId(UUID rescheduledToOccurrenceId);

    /**
     * Overlap rule:
     * existing.start < newEnd AND existing.end > newStart
     */
    @Query("""
            select o
            from ScheduleOccurrence o
            where o.userId = :userId
              and o.status in :activeStatuses
              and o.startDateTime < :endDateTime
              and o.endDateTime > :startDateTime
            order by o.startDateTime asc
            """)
    List<ScheduleOccurrence> findOverlapping(
            @Param("userId") UUID userId,
            @Param("startDateTime") LocalDateTime startDateTime,
            @Param("endDateTime") LocalDateTime endDateTime,
            @Param("activeStatuses") List<ScheduleOccurrenceStatus> activeStatuses
    );

    @Query("""
            select o
            from ScheduleOccurrence o
            where o.userId = :userId
              and o.status in :statuses
              and o.endDateTime < :nowLocalDateTime
            order by o.endDateTime asc
            """)
    List<ScheduleOccurrence> findOpenOccurrencesBefore(
            @Param("userId") UUID userId,
            @Param("nowLocalDateTime") LocalDateTime nowLocalDateTime,
            @Param("statuses") List<ScheduleOccurrenceStatus> statuses
    );

    @Query("""
            select o
            from ScheduleOccurrence o
            where o.userId = :userId
              and o.status in :statuses
              and o.startDateTime <= :nowLocalDateTime
              and o.endDateTime > :nowLocalDateTime
            order by o.startDateTime asc
            """)
    List<ScheduleOccurrence> findOccurrencesActiveAt(
            @Param("userId") UUID userId,
            @Param("nowLocalDateTime") LocalDateTime nowLocalDateTime,
            @Param("statuses") List<ScheduleOccurrenceStatus> statuses
    );
}