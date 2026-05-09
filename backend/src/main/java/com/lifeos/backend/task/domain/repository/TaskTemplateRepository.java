package com.lifeos.backend.task.domain.repository;

import com.lifeos.backend.task.domain.entity.TaskTemplate;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface TaskTemplateRepository {

    TaskTemplate save(TaskTemplate template);

    List<TaskTemplate> saveAll(List<TaskTemplate> templates);

    Optional<TaskTemplate> findById(UUID templateId);

    Optional<TaskTemplate> findByIdForUser(UUID userId, UUID templateId);

    List<TaskTemplate> findByUserId(UUID userId);

    List<TaskTemplate> findActiveByUserId(UUID userId);

    /**
     * Used by TaskSpawnerEngine.
     *
     * Finds templates that may spawn occurrences inside the window.
     */
    List<TaskTemplate> findSpawnCandidates(
            UUID userId,
            LocalDate windowStart,
            LocalDate windowEnd
    );

    void deleteById(UUID templateId);
}