package com.lifeos.backend.task.infrastructure.persistence;

import com.lifeos.backend.task.domain.entity.TaskTemplate;
import com.lifeos.backend.task.domain.enums.TaskTemplateStatus;
import com.lifeos.backend.task.domain.repository.TaskTemplateRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
public class TaskTemplateRepositoryImpl implements TaskTemplateRepository {

    private final TaskTemplateJpaRepository jpaRepository;

    @Override
    public TaskTemplate save(TaskTemplate template) {
        return jpaRepository.save(template);
    }

    @Override
    public List<TaskTemplate> saveAll(List<TaskTemplate> templates) {
        return jpaRepository.saveAll(templates);
    }

    @Override
    public Optional<TaskTemplate> findById(UUID templateId) {
        return jpaRepository.findById(templateId);
    }

    @Override
    public Optional<TaskTemplate> findByIdForUser(UUID userId, UUID templateId) {
        return jpaRepository.findById(templateId)
                .filter(template -> template.getUserId().equals(userId));
    }

    @Override
    public List<TaskTemplate> findByUserId(UUID userId) {
        return jpaRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    @Override
    public List<TaskTemplate> findActiveByUserId(UUID userId) {
        return jpaRepository
                .findByUserIdAndStatusAndArchivedFalseAndPausedFalseOrderByCreatedAtDesc(
                        userId,
                        TaskTemplateStatus.ACTIVE
                );
    }

    @Override
    public List<TaskTemplate> findSpawnCandidates(
            UUID userId,
            LocalDate windowStart,
            LocalDate windowEnd
    ) {
        return jpaRepository.findSpawnCandidates(
                userId,
                TaskTemplateStatus.ACTIVE,
                windowStart,
                windowEnd
        );
    }

    @Override
    public void deleteById(UUID templateId) {
        jpaRepository.deleteById(templateId);
    }
}