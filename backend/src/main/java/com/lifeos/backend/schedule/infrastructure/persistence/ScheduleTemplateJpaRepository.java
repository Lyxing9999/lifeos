package com.lifeos.backend.schedule.infrastructure.persistence;

import com.lifeos.backend.schedule.domain.entity.ScheduleTemplate;
import com.lifeos.backend.schedule.domain.enums.ScheduleTemplateStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public interface ScheduleTemplateJpaRepository extends JpaRepository<ScheduleTemplate, UUID> {

    List<ScheduleTemplate> findByUserIdOrderByStartTimeAscCreatedAtDesc(UUID userId);

    List<ScheduleTemplate> findByUserIdAndStatusOrderByStartTimeAscCreatedAtDesc(
            UUID userId,
            ScheduleTemplateStatus status
    );

    @Query("""
            select t
            from ScheduleTemplate t
            where t.userId = :userId
              and t.status = :activeStatus
              and (
                    t.recurrenceStartDate is null
                    or t.recurrenceStartDate <= :windowEnd
                  )
              and (
                    t.recurrenceEndDate is null
                    or t.recurrenceEndDate >= :windowStart
                  )
            order by t.startTime asc, t.createdAt asc
            """)
    List<ScheduleTemplate> findSpawnCandidates(
            @Param("userId") UUID userId,
            @Param("activeStatus") ScheduleTemplateStatus activeStatus,
            @Param("windowStart") LocalDate windowStart,
            @Param("windowEnd") LocalDate windowEnd
    );
}