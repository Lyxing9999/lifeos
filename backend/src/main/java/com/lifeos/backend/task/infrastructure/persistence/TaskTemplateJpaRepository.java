package com.lifeos.backend.task.infrastructure.persistence;

import com.lifeos.backend.task.domain.entity.TaskTemplate;
import com.lifeos.backend.task.domain.enums.TaskTemplateStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public interface TaskTemplateJpaRepository extends JpaRepository<TaskTemplate, UUID> {

    List<TaskTemplate> findByUserIdOrderByCreatedAtDesc(UUID userId);

    List<TaskTemplate> findByUserIdAndStatusAndArchivedFalseAndPausedFalseOrderByCreatedAtDesc(
            UUID userId,
            TaskTemplateStatus status
    );

    @Query("""
            select t
            from TaskTemplate t
            where t.userId = :userId
              and t.status = :activeStatus
              and t.archived = false
              and t.paused = false
              and (
                    t.recurrenceStartDate is null
                    or t.recurrenceStartDate <= :windowEnd
                  )
              and (
                    t.recurrenceEndDate is null
                    or t.recurrenceEndDate >= :windowStart
                  )
            order by t.createdAt asc
            """)
    List<TaskTemplate> findSpawnCandidates(
            @Param("userId") UUID userId,
            @Param("activeStatus") TaskTemplateStatus activeStatus,
            @Param("windowStart") LocalDate windowStart,
            @Param("windowEnd") LocalDate windowEnd
    );
}