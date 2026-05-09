package com.lifeos.backend.task.infrastructure.persistence;

import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface TaskInstanceJpaRepository extends JpaRepository<TaskInstance, UUID> {

    Optional<TaskInstance> findByIdAndUserId(UUID id, UUID userId);

    Optional<TaskInstance> findByTemplateIdAndOccurrenceDate(
            UUID templateId,
            LocalDate occurrenceDate
    );

    boolean existsByTemplateIdAndOccurrenceDate(
            UUID templateId,
            LocalDate occurrenceDate
    );

    List<TaskInstance> findByUserIdAndScheduledDateOrderByDueDateTimeAscCreatedAtAsc(
            UUID userId,
            LocalDate scheduledDate
    );

    List<TaskInstance> findByUserIdAndScheduledDateBetweenOrderByScheduledDateAscDueDateTimeAscCreatedAtAsc(
            UUID userId,
            LocalDate startDate,
            LocalDate endDate
    );

    List<TaskInstance> findByUserIdAndStatusOrderByScheduledDateAscDueDateTimeAscCreatedAtAsc(
            UUID userId,
            TaskInstanceStatus status
    );

    List<TaskInstance> findByRolledOverFromInstanceId(UUID rolledOverFromInstanceId);

    List<TaskInstance> findByRolledOverToInstanceId(UUID rolledOverToInstanceId);

    /**
     * Used by MidnightRolloverEngine.
     *
     * Finds unfinished instances whose planned day/time is at or before the target day.
     */
    @Query("""
            select i
            from TaskInstance i
            where i.userId = :userId
              and i.status in :statuses
              and (
                    (i.scheduledDate is not null and i.scheduledDate <= :targetDate)
                    or
                    (i.dueDateTime is not null and i.dueDateTime < :endExclusive)
                  )
            order by i.scheduledDate asc, i.dueDateTime asc, i.createdAt asc
            """)
    List<TaskInstance> findOpenInstancesForDayBoundary(
            @Param("userId") UUID userId,
            @Param("targetDate") LocalDate targetDate,
            @Param("endExclusive") LocalDateTime endExclusive,
            @Param("statuses") List<TaskInstanceStatus> statuses
    );

    /**
     * Used by OverdueSweepProcessor.
     *
     * Finds open instances that should be evaluated for overdue behavior.
     */
    @Query("""
            select i
            from TaskInstance i
            where i.userId = :userId
              and i.status in :statuses
              and (
                    (i.dueDateTime is not null and i.dueDateTime < :nowLocalDateTime)
                    or
                    (i.dueDateTime is null and i.scheduledDate is not null and i.scheduledDate < :targetDate)
                  )
            order by i.scheduledDate asc, i.dueDateTime asc, i.createdAt asc
            """)
    List<TaskInstance> findOverdueCandidates(
            @Param("userId") UUID userId,
            @Param("targetDate") LocalDate targetDate,
            @Param("nowLocalDateTime") LocalDateTime nowLocalDateTime,
            @Param("statuses") List<TaskInstanceStatus> statuses
    );
}