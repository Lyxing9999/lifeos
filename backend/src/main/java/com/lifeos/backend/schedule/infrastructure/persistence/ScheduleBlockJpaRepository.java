package com.lifeos.backend.schedule.infrastructure.persistence;

import com.lifeos.backend.schedule.domain.ScheduleBlock;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface ScheduleBlockJpaRepository extends JpaRepository<ScheduleBlock, UUID> {
    List<ScheduleBlock> findByUserIdOrderByStartTimeAsc(UUID userId);
    List<ScheduleBlock> findByUserIdAndActiveTrueOrderByStartTimeAsc(UUID userId);
    List<ScheduleBlock> findByUserIdAndActiveTrue(UUID userId);
    List<ScheduleBlock> findByUserId(UUID userId);
}