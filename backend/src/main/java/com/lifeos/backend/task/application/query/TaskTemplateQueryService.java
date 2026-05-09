package com.lifeos.backend.task.application.query;

import com.lifeos.backend.common.exception.NotFoundException;
import com.lifeos.backend.task.domain.entity.TaskTemplate;
import com.lifeos.backend.task.domain.repository.TaskTemplateRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

/**
 * Read-side service for TaskTemplate.
 *
 * TaskTemplate = blueprint / intent / recurrence rule.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class TaskTemplateQueryService {

    private final TaskTemplateRepository taskTemplateRepository;

    public TaskTemplate getByIdForUser(UUID userId, UUID templateId) {
        validateUserId(userId);
        validateTemplateId(templateId);

        return taskTemplateRepository.findByIdForUser(userId, templateId)
                .orElseThrow(() -> new NotFoundException("Task template not found"));
    }

    public List<TaskTemplate> getAllForUser(UUID userId) {
        validateUserId(userId);
        return taskTemplateRepository.findByUserId(userId);
    }

    public List<TaskTemplate> getActiveForUser(UUID userId) {
        validateUserId(userId);
        return taskTemplateRepository.findActiveByUserId(userId);
    }

    public List<TaskTemplate> getPausedForUser(UUID userId) {
        validateUserId(userId);

        return taskTemplateRepository.findByUserId(userId)
                .stream()
                .filter(TaskTemplate::isPaused)
                .toList();
    }

    public List<TaskTemplate> getArchivedForUser(UUID userId) {
        validateUserId(userId);

        return taskTemplateRepository.findByUserId(userId)
                .stream()
                .filter(TaskTemplate::isArchived)
                .toList();
    }

    public List<TaskTemplate> getRecurringForUser(UUID userId) {
        validateUserId(userId);

        return taskTemplateRepository.findByUserId(userId)
                .stream()
                .filter(TaskTemplate::isRecurring)
                .toList();
    }

    public List<TaskTemplate> getActiveRecurringForUser(UUID userId) {
        validateUserId(userId);

        return taskTemplateRepository.findActiveByUserId(userId)
                .stream()
                .filter(TaskTemplate::isRecurring)
                .toList();
    }

    private void validateUserId(UUID userId) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }
    }

    private void validateTemplateId(UUID templateId) {
        if (templateId == null) {
            throw new IllegalArgumentException("templateId is required");
        }
    }
}