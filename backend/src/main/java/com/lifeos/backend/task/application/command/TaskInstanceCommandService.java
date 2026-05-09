package com.lifeos.backend.task.application.command;

import com.lifeos.backend.common.exception.NotFoundException;
import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.task.application.command.TaskCompletionService.DoneCleanupResult;
import com.lifeos.backend.task.application.command.TaskLifecycleOrchestrator.TaskLifecycleResult;
import com.lifeos.backend.task.application.command.TaskSkipOccurrenceService.SkipOccurrenceResult;
import com.lifeos.backend.task.application.factory.TaskInstanceFactory;
import com.lifeos.backend.task.domain.entity.MutationHistory;
import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.enums.MutationType;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.task.domain.enums.TaskPriority;
import com.lifeos.backend.task.domain.enums.TaskTransitionType;
import com.lifeos.backend.task.domain.repository.MutationHistoryRepository;
import com.lifeos.backend.task.domain.repository.TaskInstanceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Public command service for TaskInstance.
 *
 * TaskInstance = actual executable work item.
 *
 * This service is controller-facing and delegates lifecycle behavior
 * to TaskLifecycleOrchestrator / specialized command services.
 */
@Service
@RequiredArgsConstructor
public class TaskInstanceCommandService {

    private final TaskInstanceRepository taskInstanceRepository;
    private final MutationHistoryRepository mutationHistoryRepository;
    private final TaskInstanceFactory taskInstanceFactory;

    private final TaskLifecycleOrchestrator lifecycleOrchestrator;
    private final TaskCompletionService taskCompletionService;
    private final TaskRescheduleService taskRescheduleService;
    private final TaskSkipOccurrenceService taskSkipOccurrenceService;

    private final UserTimeService userTimeService;

    /**
     * Create manual inbox task.
     *
     * Example:
     * User quickly captures: "Buy notebook"
     */
    @Transactional
    public TaskInstance createInbox(CreateInboxTaskCommand command) {
        validateCreateInbox(command);

        TaskInstance instance = taskInstanceFactory.createManualInbox(
                command.userId(),
                command.title(),
                command.description(),
                command.priority(),
                command.category()
        );

        TaskInstance saved = taskInstanceRepository.save(instance);

        mutationHistoryRepository.save(
                MutationHistory.lifecycle(
                        saved.getUserId(),
                        saved.getTemplateId(),
                        saved.getId(),
                        MutationType.INSTANCE_CREATED,
                        TaskTransitionType.CREATE,
                        null,
                        saved.getStatus(),
                        "USER",
                        "Manual inbox task created"
                )
        );

        return saved;
    }

    /**
     * Create manual scheduled one-time task.
     *
     * Example:
     * "Submit homework" on 2026-05-09.
     */
    @Transactional
    public TaskInstance createScheduled(CreateScheduledTaskCommand command) {
        validateCreateScheduled(command);

        LocalDate userToday = resolveUserToday(command.userId());

        TaskInstance instance = taskInstanceFactory.createManualScheduled(
                command.userId(),
                command.title(),
                command.description(),
                command.priority(),
                command.category(),
                command.scheduledDate(),
                command.dueDateTime(),
                userToday
        );

        TaskInstance saved = taskInstanceRepository.save(instance);

        mutationHistoryRepository.save(
                MutationHistory.lifecycle(
                        saved.getUserId(),
                        saved.getTemplateId(),
                        saved.getId(),
                        MutationType.INSTANCE_SPAWNED,
                        TaskTransitionType.SPAWN,
                        null,
                        saved.getStatus(),
                        "USER",
                        "Manual scheduled task created"
                )
        );

        return saved;
    }

    @Transactional
    public TaskLifecycleResult start(UUID userId, UUID taskInstanceId) {
        return lifecycleOrchestrator.start(userId, taskInstanceId);
    }

    @Transactional
    public TaskLifecycleResult complete(UUID userId, UUID taskInstanceId) {
        return taskCompletionService.complete(userId, taskInstanceId);
    }

    @Transactional
    public TaskLifecycleResult reopen(
            UUID userId,
            UUID taskInstanceId,
            String reason
    ) {
        return taskCompletionService.reopen(userId, taskInstanceId, reason);
    }

    @Transactional
    public TaskLifecycleResult markOverdue(
            UUID userId,
            UUID taskInstanceId,
            String reason
    ) {
        return lifecycleOrchestrator.markOverdue(
                userId,
                taskInstanceId,
                "ENGINE",
                reason
        );
    }

    @Transactional
    public TaskLifecycleResult markMissed(
            UUID userId,
            UUID taskInstanceId,
            String reason
    ) {
        return lifecycleOrchestrator.markMissed(
                userId,
                taskInstanceId,
                "ENGINE",
                reason
        );
    }

    @Transactional
    public TaskLifecycleResult reschedule(
            UUID userId,
            UUID taskInstanceId,
            LocalDate targetScheduledDate,
            LocalDateTime targetDueDateTime,
            String reason
    ) {
        return taskRescheduleService.rescheduleInstance(
                userId,
                taskInstanceId,
                targetScheduledDate,
                targetDueDateTime,
                reason
        );
    }

    @Transactional
    public TaskLifecycleResult rollover(
            UUID userId,
            UUID taskInstanceId,
            LocalDate targetScheduledDate,
            LocalDateTime targetDueDateTime,
            String reason
    ) {
        return lifecycleOrchestrator.rollover(
                userId,
                taskInstanceId,
                targetScheduledDate,
                targetDueDateTime,
                "USER",
                reason
        );
    }

    @Transactional
    public TaskLifecycleResult pause(
            UUID userId,
            UUID taskInstanceId,
            String reason
    ) {
        return lifecycleOrchestrator.pause(userId, taskInstanceId, reason);
    }

    @Transactional
    public TaskLifecycleResult resume(
            UUID userId,
            UUID taskInstanceId,
            String reason
    ) {
        return lifecycleOrchestrator.resume(userId, taskInstanceId, reason);
    }

    @Transactional
    public TaskLifecycleResult archive(
            UUID userId,
            UUID taskInstanceId,
            String reason
    ) {
        return lifecycleOrchestrator.archive(userId, taskInstanceId, reason);
    }

    @Transactional
    public TaskLifecycleResult restore(
            UUID userId,
            UUID taskInstanceId,
            String reason
    ) {
        return lifecycleOrchestrator.restore(userId, taskInstanceId, reason);
    }

    @Transactional
    public TaskLifecycleResult cancel(
            UUID userId,
            UUID taskInstanceId,
            String reason
    ) {
        return lifecycleOrchestrator.cancel(userId, taskInstanceId, reason);
    }

    @Transactional
    public TaskLifecycleResult clearFromDone(
            UUID userId,
            UUID taskInstanceId
    ) {
        return taskCompletionService.clearFromDone(userId, taskInstanceId);
    }

    @Transactional
    public TaskLifecycleResult restoreToDone(
            UUID userId,
            UUID taskInstanceId
    ) {
        return taskCompletionService.restoreToDone(userId, taskInstanceId);
    }

    @Transactional
    public DoneCleanupResult clearDoneForDay(
            UUID userId,
            LocalDate date
    ) {
        return taskCompletionService.clearDoneForDay(userId, date);
    }

    @Transactional
    public DoneCleanupResult restoreDoneForDay(
            UUID userId,
            LocalDate date
    ) {
        return taskCompletionService.restoreDoneForDay(userId, date);
    }

    /**
     * Skip existing instance.
     */
    @Transactional
    public TaskLifecycleResult skipExistingOccurrence(
            UUID userId,
            UUID taskInstanceId,
            String reason
    ) {
        return taskSkipOccurrenceService.skipExistingOccurrence(
                userId,
                taskInstanceId,
                reason
        );
    }

    /**
     * Smart skip by template + occurrenceDate.
     *
     * If instance exists, mark SKIPPED.
     * If not, create occurrence exception so spawner will not create it.
     */
    @Transactional
    public SkipOccurrenceResult skipOccurrence(
            UUID userId,
            UUID templateId,
            LocalDate occurrenceDate,
            String reason
    ) {
        return taskSkipOccurrenceService.skipOccurrence(
                userId,
                templateId,
                occurrenceDate,
                reason
        );
    }

    /**
     * Hard delete.
     *
     * Prefer archive() for dogfooding so history is preserved.
     */
    @Transactional
    public void delete(UUID userId, UUID taskInstanceId) {
        TaskInstance instance = taskInstanceRepository
                .findByIdForUser(userId, taskInstanceId)
                .orElseThrow(() -> new NotFoundException("Task instance not found"));

        taskInstanceRepository.deleteById(instance.getId());
    }

    private LocalDate resolveUserToday(UUID userId) {
        return Instant.now()
                .atZone(userTimeService.getUserZoneId(userId))
                .toLocalDate();
    }

    private void validateCreateInbox(CreateInboxTaskCommand command) {
        if (command == null) {
            throw new IllegalArgumentException("CreateInboxTaskCommand is required");
        }

        if (command.userId() == null) {
            throw new IllegalArgumentException("userId is required");
        }

        requireTitle(command.title());
    }

    private void validateCreateScheduled(CreateScheduledTaskCommand command) {
        if (command == null) {
            throw new IllegalArgumentException("CreateScheduledTaskCommand is required");
        }

        if (command.userId() == null) {
            throw new IllegalArgumentException("userId is required");
        }

        requireTitle(command.title());

        if (command.scheduledDate() == null && command.dueDateTime() == null) {
            throw new IllegalArgumentException("scheduledDate or dueDateTime is required");
        }
    }

    private void requireTitle(String title) {
        if (title == null || title.isBlank()) {
            throw new IllegalArgumentException("title is required");
        }
    }

    public record CreateInboxTaskCommand(
            UUID userId,
            String title,
            String description,
            TaskPriority priority,
            String category
    ) {
    }

    public record CreateScheduledTaskCommand(
            UUID userId,
            String title,
            String description,
            TaskPriority priority,
            String category,
            LocalDate scheduledDate,
            LocalDateTime dueDateTime
    ) {
    }
}