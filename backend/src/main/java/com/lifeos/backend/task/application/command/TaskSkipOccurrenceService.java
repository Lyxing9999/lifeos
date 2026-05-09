package com.lifeos.backend.task.application.command;

import com.lifeos.backend.common.exception.NotFoundException;
import com.lifeos.backend.task.application.command.TaskLifecycleOrchestrator.TaskLifecycleResult;
import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.entity.TaskOccurrenceException;
import com.lifeos.backend.task.domain.entity.TaskTemplate;
import com.lifeos.backend.task.domain.repository.TaskInstanceRepository;
import com.lifeos.backend.task.domain.repository.TaskTemplateRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.UUID;

/**
 * Application service for SKIP_OCCURRENCE.
 *
 * There are two cases:
 *
 * 1. Instance already exists:
 *    - mark TaskInstance as SKIPPED
 *    - create/update TaskOccurrenceException(SKIPPED)
 *
 * 2. Instance does not exist yet:
 *    - create TaskOccurrenceException(SKIPPED)
 *    - spawner will avoid creating it later
 */
@Service
@RequiredArgsConstructor
public class TaskSkipOccurrenceService {

    private final TaskLifecycleOrchestrator lifecycleOrchestrator;
    private final TaskInstanceRepository taskInstanceRepository;
    private final TaskTemplateRepository taskTemplateRepository;

    /**
     * Skip an existing spawned task instance.
     */
    @Transactional
    public TaskLifecycleResult skipExistingOccurrence(
            UUID userId,
            UUID taskInstanceId,
            String reason
    ) {
        return lifecycleOrchestrator.skipExistingOccurrence(
                userId,
                taskInstanceId,
                reason
        );
    }

    /**
     * Skip a future recurring occurrence before it is spawned.
     */
    @Transactional
    public TaskOccurrenceException skipFutureOccurrence(
            UUID userId,
            UUID templateId,
            LocalDate occurrenceDate,
            String reason
    ) {
        validateTemplateOwnership(userId, templateId);

        return lifecycleOrchestrator.skipFutureOccurrence(
                userId,
                templateId,
                occurrenceDate,
                reason
        );
    }

    /**
     * Smart skip:
     * - if an instance exists for templateId + occurrenceDate, skip that instance
     * - otherwise create a future skip exception
     */
    @Transactional
    public SkipOccurrenceResult skipOccurrence(
            UUID userId,
            UUID templateId,
            LocalDate occurrenceDate,
            String reason
    ) {
        validateTemplateOwnership(userId, templateId);

        if (occurrenceDate == null) {
            throw new IllegalArgumentException("occurrenceDate is required");
        }

        TaskInstance existing = taskInstanceRepository
                .findByTemplateIdAndOccurrenceDate(templateId, occurrenceDate)
                .filter(instance -> instance.getUserId().equals(userId))
                .orElse(null);

        if (existing != null) {
            TaskLifecycleResult lifecycleResult =
                    lifecycleOrchestrator.skipExistingOccurrence(
                            userId,
                            existing.getId(),
                            reason
                    );

            return SkipOccurrenceResult.existingInstanceSkipped(
                    lifecycleResult
            );
        }

        TaskOccurrenceException exception =
                lifecycleOrchestrator.skipFutureOccurrence(
                        userId,
                        templateId,
                        occurrenceDate,
                        reason
                );

        return SkipOccurrenceResult.futureOccurrenceSkipped(exception);
    }

    private void validateTemplateOwnership(UUID userId, UUID templateId) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }

        if (templateId == null) {
            throw new IllegalArgumentException("templateId is required");
        }

        TaskTemplate template = taskTemplateRepository
                .findByIdForUser(userId, templateId)
                .orElseThrow(() -> new NotFoundException("Task template not found"));

        if (!template.isRecurring()) {
            throw new IllegalArgumentException(
                    "Only recurring task template occurrences can be skipped"
            );
        }
    }

    public record SkipOccurrenceResult(
            boolean existingInstance,
            TaskLifecycleResult lifecycleResult,
            TaskOccurrenceException occurrenceException
    ) {
        public static SkipOccurrenceResult existingInstanceSkipped(
                TaskLifecycleResult lifecycleResult
        ) {
            return new SkipOccurrenceResult(
                    true,
                    lifecycleResult,
                    null
            );
        }

        public static SkipOccurrenceResult futureOccurrenceSkipped(
                TaskOccurrenceException occurrenceException
        ) {
            return new SkipOccurrenceResult(
                    false,
                    null,
                    occurrenceException
            );
        }
    }
}