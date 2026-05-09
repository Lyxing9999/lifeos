package com.lifeos.backend.task.domain.repository;

import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface TaskInstanceRepository {

    TaskInstance save(TaskInstance instance);

    List<TaskInstance> saveAll(List<TaskInstance> instances);

    Optional<TaskInstance> findById(UUID instanceId);

    Optional<TaskInstance> findByIdForUser(UUID userId, UUID instanceId);

    Optional<TaskInstance> findByTemplateIdAndOccurrenceDate(
            UUID templateId,
            LocalDate occurrenceDate
    );

    boolean existsByTemplateIdAndOccurrenceDate(
            UUID templateId,
            LocalDate occurrenceDate
    );

    List<TaskInstance> findByUserIdAndScheduledDate(
            UUID userId,
            LocalDate scheduledDate
    );

    List<TaskInstance> findByUserIdAndScheduledDateBetween(
            UUID userId,
            LocalDate startDate,
            LocalDate endDate
    );

    List<TaskInstance> findByUserIdAndStatus(
            UUID userId,
            TaskInstanceStatus status
    );

    List<TaskInstance> findOpenInstancesForDayBoundary(
            UUID userId,
            LocalDate targetDate,
            LocalDateTime endExclusive,
            List<TaskInstanceStatus> statuses
    );

    List<TaskInstance> findOverdueCandidates(
            UUID userId,
            LocalDate targetDate,
            LocalDateTime nowLocalDateTime,
            List<TaskInstanceStatus> statuses
    );

    List<TaskInstance> findByRolledOverFromInstanceId(UUID sourceInstanceId);

    List<TaskInstance> findByRolledOverToInstanceId(UUID targetInstanceId);

    void deleteById(UUID instanceId);
}