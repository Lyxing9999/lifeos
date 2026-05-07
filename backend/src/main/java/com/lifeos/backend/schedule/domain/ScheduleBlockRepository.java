package com.lifeos.backend.schedule.domain;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ScheduleBlockRepository {
    ScheduleBlock save(ScheduleBlock block);
    List<ScheduleBlock> saveAll(List<ScheduleBlock> blocks);
    Optional<ScheduleBlock> findById(UUID id);
    void deleteById(UUID id);
    List<ScheduleBlock> findAll();

    // The new optimized queries
    List<ScheduleBlock> findUnarchivedByUserId(UUID userId);
    List<ScheduleBlock> findArchivedByUserId(UUID userId);

}