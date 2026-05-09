package com.lifeos.backend.task.infrastructure.persistence;

import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.task.domain.repository.TaskInstanceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
public class TaskInstanceRepositoryImpl implements TaskInstanceRepository {

    private final TaskInstanceJpaRepository jpaRepository;

    @Override
    public TaskInstance save(TaskInstance instance) {
        return jpaRepository.save(instance);
    }

    @Override
    public List<TaskInstance> saveAll(List<TaskInstance> instances) {
        return jpaRepository.saveAll(instances);
    }

    @Override
    public Optional<TaskInstance> findById(UUID instanceId) {
        return jpaRepository.findById(instanceId);
    }

    @Override
    public Optional<TaskInstance> findByIdForUser(UUID userId, UUID instanceId) {
        return jpaRepository.findByIdAndUserId(instanceId, userId);
    }

    @Override
    public Optional<TaskInstance> findByTemplateIdAndOccurrenceDate(
            UUID templateId,
            LocalDate occurrenceDate
    ) {
        return jpaRepository.findByTemplateIdAndOccurrenceDate(templateId, occurrenceDate);
    }

    @Override
    public boolean existsByTemplateIdAndOccurrenceDate(
            UUID templateId,
            LocalDate occurrenceDate
    ) {
        return jpaRepository.existsByTemplateIdAndOccurrenceDate(templateId, occurrenceDate);
    }

    @Override
    public List<TaskInstance> findByUserIdAndScheduledDate(
            UUID userId,
            LocalDate scheduledDate
    ) {
        return jpaRepository.findByUserIdAndScheduledDateOrderByDueDateTimeAscCreatedAtAsc(
                userId,
                scheduledDate
        );
    }

    @Override
    public List<TaskInstance> findByUserIdAndScheduledDateBetween(
            UUID userId,
            LocalDate startDate,
            LocalDate endDate
    ) {
        return jpaRepository
                .findByUserIdAndScheduledDateBetweenOrderByScheduledDateAscDueDateTimeAscCreatedAtAsc(
                        userId,
                        startDate,
                        endDate
                );
    }

    @Override
    public List<TaskInstance> findByUserIdAndStatus(
            UUID userId,
            TaskInstanceStatus status
    ) {
        return jpaRepository.findByUserIdAndStatusOrderByScheduledDateAscDueDateTimeAscCreatedAtAsc(
                userId,
                status
        );
    }

    @Override
    public List<TaskInstance> findOpenInstancesForDayBoundary(
            UUID userId,
            LocalDate targetDate,
            LocalDateTime endExclusive,
            List<TaskInstanceStatus> statuses
    ) {
        return jpaRepository.findOpenInstancesForDayBoundary(
                userId,
                targetDate,
                endExclusive,
                statuses
        );
    }

    @Override
    public List<TaskInstance> findOverdueCandidates(
            UUID userId,
            LocalDate targetDate,
            LocalDateTime nowLocalDateTime,
            List<TaskInstanceStatus> statuses
    ) {
        return jpaRepository.findOverdueCandidates(
                userId,
                targetDate,
                nowLocalDateTime,
                statuses
        );
    }

    @Override
    public List<TaskInstance> findByRolledOverFromInstanceId(UUID sourceInstanceId) {
        return jpaRepository.findByRolledOverFromInstanceId(sourceInstanceId);
    }

    @Override
    public List<TaskInstance> findByRolledOverToInstanceId(UUID targetInstanceId) {
        return jpaRepository.findByRolledOverToInstanceId(targetInstanceId);
    }

    @Override
    public void deleteById(UUID instanceId) {
        jpaRepository.deleteById(instanceId);
    }
}