package com.lifeos.backend.schedule.domain;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ScheduleBlockRepository {

    ScheduleBlock save(ScheduleBlock block);

    List<ScheduleBlock> saveAll(List<ScheduleBlock> blocks);

    Optional<ScheduleBlock> findById(UUID id);

    List<ScheduleBlock> findByUserId(UUID userId);

    List<ScheduleBlock> findByUserIdAndActiveTrue(UUID userId);

    void deleteById(UUID id);
}