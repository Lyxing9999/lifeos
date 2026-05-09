package com.lifeos.backend.schedule.domain.repository;

import com.lifeos.backend.schedule.domain.entity.ScheduleTemplate;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ScheduleTemplateRepository {

    ScheduleTemplate save(ScheduleTemplate template);

    List<ScheduleTemplate> saveAll(List<ScheduleTemplate> templates);

    Optional<ScheduleTemplate> findById(UUID templateId);

    Optional<ScheduleTemplate> findByIdForUser(UUID userId, UUID templateId);

    List<ScheduleTemplate> findByUserId(UUID userId);

    List<ScheduleTemplate> findActiveByUserId(UUID userId);

    List<ScheduleTemplate> findPausedByUserId(UUID userId);

    List<ScheduleTemplate> findArchivedByUserId(UUID userId);

    /**
     * Used by ScheduleSpawnerService.
     *
     * Finds templates that may spawn occurrences inside the window.
     */
    List<ScheduleTemplate> findSpawnCandidates(
            UUID userId,
            LocalDate windowStart,
            LocalDate windowEnd
    );

    void deleteById(UUID templateId);
}