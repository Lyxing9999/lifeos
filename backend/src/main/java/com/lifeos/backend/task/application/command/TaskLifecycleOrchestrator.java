package com.lifeos.backend.task.application.command;

import com.lifeos.backend.common.exception.NotFoundException;
import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.task.application.factory.TaskInstanceFactory;
import com.lifeos.backend.task.domain.entity.CompletionLog;
import com.lifeos.backend.task.domain.entity.MutationHistory;
import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.entity.TaskOccurrenceException;
import com.lifeos.backend.task.domain.enums.MutationType;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.task.domain.enums.TaskOccurrenceExceptionScope;
import com.lifeos.backend.task.domain.enums.TaskOccurrenceExceptionType;
import com.lifeos.backend.task.domain.enums.TaskTransitionType;
import com.lifeos.backend.task.domain.repository.CompletionLogRepository;
import com.lifeos.backend.task.domain.repository.MutationHistoryRepository;
import com.lifeos.backend.task.domain.repository.TaskInstanceRepository;
import com.lifeos.backend.task.domain.repository.TaskOccurrenceExceptionRepository;
import com.lifeos.backend.task.domain.statemachine.TaskStateContext;
import com.lifeos.backend.task.domain.statemachine.TaskStateMachine;
import com.lifeos.backend.task.domain.statemachine.TaskTransitionCommand;
import com.lifeos.backend.task.domain.statemachine.TaskTransitionResult;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.UUID;

/**
 * Application orchestrator for task lifecycle transitions.
 *
 * Responsibilities:
 * - load owned TaskInstance
 * - build timezone-safe TaskStateContext
 * - call TaskStateMachine
 * - save mutated TaskInstance
 * - save MutationHistory
 * - save CompletionLog when completed
 * - create rollover target instance
 * - create/update occurrence exceptions for RESCHEDULE / SKIP_OCCURRENCE
 *
 * Important:
 * State machine mutates the instance.
 * Orchestrator persists and coordinates side effects.
 */
@Service
@RequiredArgsConstructor
public class TaskLifecycleOrchestrator {

    private final TaskInstanceRepository taskInstanceRepository;
    private final TaskOccurrenceExceptionRepository occurrenceExceptionRepository;
    private final MutationHistoryRepository mutationHistoryRepository;
    private final CompletionLogRepository completionLogRepository;
    private final TaskInstanceFactory taskInstanceFactory;
    private final TaskStateMachine taskStateMachine;
    private final UserTimeService userTimeService;

    /**
     * Generic lifecycle transition.
     *
     * Use this for simple transitions:
     * - START
     * - COMPLETE
     * - REOPEN
     * - MARK_OVERDUE
     * - MARK_MISSED
     * - PAUSE
     * - RESUME
     * - ARCHIVE
     * - RESTORE
     * - CANCEL
     * - CLEAR_FROM_DONE
     * - RESTORE_TO_DONE
     */
    @Transactional
    public TaskLifecycleResult transition(
            UUID userId,
            UUID taskInstanceId,
            TaskTransitionType transitionType
    ) {
        TaskTransitionCommand command = TaskTransitionCommand.of(
                transitionType,
                userId,
                taskInstanceId
        );

        return applyAndPersist(command);
    }

    @Transactional
    public TaskLifecycleResult start(UUID userId, UUID taskInstanceId) {
        return transition(userId, taskInstanceId, TaskTransitionType.START);
    }

    @Transactional
    public TaskLifecycleResult complete(UUID userId, UUID taskInstanceId) {
        return applyAndPersist(
                TaskTransitionCommand.complete(userId, taskInstanceId)
        );
    }

    @Transactional
    public TaskLifecycleResult reopen(
            UUID userId,
            UUID taskInstanceId,
            String reason
    ) {
        return applyAndPersist(
                TaskTransitionCommand.reopen(userId, taskInstanceId, reason)
        );
    }

    @Transactional
    public TaskLifecycleResult markOverdue(
            UUID userId,
            UUID taskInstanceId,
            String actor,
            String reason
    ) {
        TaskTransitionCommand command = new TaskTransitionCommand(
                TaskTransitionType.MARK_OVERDUE,
                userId,
                taskInstanceId,
                null,
                null,
                null,
                null,
                reason,
                actor == null ? "ENGINE" : actor,
                null
        );

        return applyAndPersist(command);
    }

    @Transactional
    public TaskLifecycleResult markMissed(
            UUID userId,
            UUID taskInstanceId,
            String actor,
            String reason
    ) {
        return applyAndPersist(
                TaskTransitionCommand.markMissed(
                        userId,
                        taskInstanceId,
                        actor,
                        reason
                )
        );
    }

    @Transactional
    public TaskLifecycleResult pause(
            UUID userId,
            UUID taskInstanceId,
            String reason
    ) {
        TaskTransitionCommand command = new TaskTransitionCommand(
                TaskTransitionType.PAUSE,
                userId,
                taskInstanceId,
                null,
                null,
                null,
                null,
                reason,
                "USER",
                null
        );

        return applyAndPersist(command);
    }

    @Transactional
    public TaskLifecycleResult resume(
            UUID userId,
            UUID taskInstanceId,
            String reason
    ) {
        TaskTransitionCommand command = new TaskTransitionCommand(
                TaskTransitionType.RESUME,
                userId,
                taskInstanceId,
                null,
                null,
                null,
                null,
                reason,
                "USER",
                null
        );

        return applyAndPersist(command);
    }

    @Transactional
    public TaskLifecycleResult archive(
            UUID userId,
            UUID taskInstanceId,
            String reason
    ) {
        TaskTransitionCommand command = new TaskTransitionCommand(
                TaskTransitionType.ARCHIVE,
                userId,
                taskInstanceId,
                null,
                null,
                null,
                null,
                reason,
                "USER",
                null
        );

        return applyAndPersist(command);
    }

    @Transactional
    public TaskLifecycleResult restore(
            UUID userId,
            UUID taskInstanceId,
            String reason
    ) {
        TaskTransitionCommand command = new TaskTransitionCommand(
                TaskTransitionType.RESTORE,
                userId,
                taskInstanceId,
                null,
                null,
                null,
                null,
                reason,
                "USER",
                null
        );

        return applyAndPersist(command);
    }

    @Transactional
    public TaskLifecycleResult cancel(
            UUID userId,
            UUID taskInstanceId,
            String reason
    ) {
        TaskTransitionCommand command = new TaskTransitionCommand(
                TaskTransitionType.CANCEL,
                userId,
                taskInstanceId,
                null,
                null,
                null,
                null,
                reason,
                "USER",
                null
        );

        return applyAndPersist(command);
    }

    @Transactional
    public TaskLifecycleResult clearFromDone(UUID userId, UUID taskInstanceId) {
        return transition(userId, taskInstanceId, TaskTransitionType.CLEAR_FROM_DONE);
    }

    @Transactional
    public TaskLifecycleResult restoreToDone(UUID userId, UUID taskInstanceId) {
        return transition(userId, taskInstanceId, TaskTransitionType.RESTORE_TO_DONE);
    }

    /**
     * RESCHEDULE existing instance.
     *
     * If this instance came from a recurring template, this also records
     * a TaskOccurrenceException(type = RESCHEDULED) for THIS_OCCURRENCE.
     */
    @Transactional
    public TaskLifecycleResult reschedule(
            UUID userId,
            UUID taskInstanceId,
            LocalDate targetScheduledDate,
            LocalDateTime targetDueDateTime,
            String reason
    ) {
        TaskTransitionCommand command = TaskTransitionCommand.reschedule(
                userId,
                taskInstanceId,
                targetScheduledDate,
                targetDueDateTime,
                reason
        );

        TaskLifecycleResult result = applyAndPersist(command);

        TaskInstance instance = result.instance();

        if (instance.getTemplateId() != null && instance.getOccurrenceDate() != null) {
            upsertRescheduleException(
                    instance,
                    command.resolvedTargetScheduledDate(),
                    targetDueDateTime,
                    reason
            );
        }

        return result;
    }

    /**
     * ROLLOVER existing instance.
     *
     * Behavior:
     * 1. Old instance becomes ROLLED_OVER.
     * 2. New target instance is created for target date.
     * 3. Old and new are linked.
     * 4. MutationHistory records both old rollover and new target creation.
     *
     * Important:
     * The rollover target is sourceType = ROLLOVER.
     * To avoid conflicting with the recurring template unique constraint
     * template_id + occurrence_date, the target is detached from templateId.
     * Its source is tracked through rolledOverFromInstanceId.
     */
    @Transactional
    public TaskLifecycleResult rollover(
            UUID userId,
            UUID taskInstanceId,
            LocalDate targetScheduledDate,
            LocalDateTime targetDueDateTime,
            String actor,
            String reason
    ) {
        TaskInstance source = findOwnedInstance(userId, taskInstanceId);
        TaskStateContext context = buildContext(userId, actor == null ? "ENGINE" : actor);

        TaskTransitionCommand command = TaskTransitionCommand.rollover(
                userId,
                taskInstanceId,
                targetScheduledDate,
                targetDueDateTime,
                actor == null ? "ENGINE" : actor,
                reason
        );

        TaskTransitionResult sourceResult = taskStateMachine.apply(
                source,
                command,
                context
        );

        LocalDate resolvedTargetDate = command.resolvedTargetScheduledDate();

        TaskInstance target = taskInstanceFactory.createRolloverTarget(
                source,
                resolvedTargetDate,
                targetDueDateTime,
                context.userToday()
        );

        /**
         * Important correction:
         * Rollover target is carried-over work, not the original recurring occurrence.
         * Detach it from templateId to avoid unique(template_id, occurrence_date) conflicts.
         */
        target.setTemplateId(null);
        target.setOccurrenceDate(resolvedTargetDate);
        target.setRolledOverFromInstanceId(source.getId());

        TaskInstance savedTarget = taskInstanceRepository.save(target);

        source.setRolledOverToInstanceId(savedTarget.getId());
        TaskInstance savedSource = taskInstanceRepository.save(source);

        mutationHistoryRepository.save(
                sourceResult.toMutationHistory()
        );

        mutationHistoryRepository.save(
                MutationHistory.lifecycle(
                        savedTarget.getUserId(),
                        savedTarget.getTemplateId(),
                        savedTarget.getId(),
                        MutationType.INSTANCE_CREATED,
                        TaskTransitionType.CREATE,
                        null,
                        savedTarget.getStatus(),
                        command.safeActor(),
                        "Rollover target created from instance " + savedSource.getId()
                )
        );

        return new TaskLifecycleResult(
                savedSource,
                sourceResult,
                savedTarget,
                List.of()
        );
    }

    /**
     * SKIP_OCCURRENCE when an instance already exists.
     *
     * This:
     * - marks instance as SKIPPED
     * - records TaskOccurrenceException(type = SKIPPED)
     */
    @Transactional
    public TaskLifecycleResult skipExistingOccurrence(
            UUID userId,
            UUID taskInstanceId,
            String reason
    ) {
        TaskInstance instance = findOwnedInstance(userId, taskInstanceId);

        TaskTransitionCommand command = TaskTransitionCommand.skipOccurrence(
                userId,
                taskInstanceId,
                instance.getTemplateId(),
                instance.getOccurrenceDate(),
                reason
        );

        TaskLifecycleResult result = applyAndPersist(command);

        TaskInstance skipped = result.instance();

        if (skipped.getTemplateId() != null && skipped.getOccurrenceDate() != null) {
            upsertSkipException(skipped, reason);
        }

        return result;
    }

    /**
     * SKIP_OCCURRENCE before the instance exists.
     *
     * Example:
     * User skips tomorrow's recurring task before the spawner creates it.
     *
     * This only creates TaskOccurrenceException.
     * TaskSpawnerService will later see it and avoid spawning.
     */
    @Transactional
    public TaskOccurrenceException skipFutureOccurrence(
            UUID userId,
            UUID templateId,
            LocalDate occurrenceDate,
            String reason
    ) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }

        if (templateId == null) {
            throw new IllegalArgumentException("templateId is required");
        }

        if (occurrenceDate == null) {
            throw new IllegalArgumentException("occurrenceDate is required");
        }

        TaskOccurrenceException exception = occurrenceExceptionRepository
                .findByTemplateIdAndOccurrenceDate(templateId, occurrenceDate)
                .orElseGet(TaskOccurrenceException::new);

        exception.setUserId(userId);
        exception.setTemplateId(templateId);
        exception.setOccurrenceDate(occurrenceDate);
        exception.setType(TaskOccurrenceExceptionType.SKIPPED);
        exception.setScope(TaskOccurrenceExceptionScope.THIS_OCCURRENCE);
        exception.setReason(reason);
        exception.markApplied();

        TaskOccurrenceException saved = occurrenceExceptionRepository.save(exception);

        mutationHistoryRepository.save(
                MutationHistory.lifecycle(
                        userId,
                        templateId,
                        null,
                        MutationType.INSTANCE_SKIPPED,
                        TaskTransitionType.SKIP_OCCURRENCE,
                        null,
                        TaskInstanceStatus.SKIPPED,
                        "USER",
                        reason
                )
        );

        return saved;
    }

    private TaskLifecycleResult applyAndPersist(TaskTransitionCommand command) {
        if (command == null) {
            throw new IllegalArgumentException("TaskTransitionCommand is required");
        }

        if (command.userId() == null) {
            throw new IllegalArgumentException("userId is required");
        }

        if (command.taskInstanceId() == null) {
            throw new IllegalArgumentException("taskInstanceId is required");
        }

        TaskInstance instance = findOwnedInstance(
                command.userId(),
                command.taskInstanceId()
        );

        TaskStateContext context = buildContext(
                command.userId(),
                command.safeActor()
        );

        TaskTransitionResult result = taskStateMachine.apply(
                instance,
                command,
                context
        );

        TaskInstance saved = taskInstanceRepository.save(instance);

        if (result.changed()) {
            mutationHistoryRepository.save(result.toMutationHistory());
            createCompletionLogIfNeeded(saved, result, context);
        }

        return new TaskLifecycleResult(
                saved,
                result,
                null,
                result.messages()
        );
    }

    private void createCompletionLogIfNeeded(
            TaskInstance instance,
            TaskTransitionResult result,
            TaskStateContext context
    ) {
        if (result.transitionType() != TaskTransitionType.COMPLETE) {
            return;
        }

        if (instance.getStatus() != TaskInstanceStatus.COMPLETED) {
            return;
        }

        boolean alreadyLogged = completionLogRepository
                .findByTaskInstanceId(instance.getId())
                .isPresent();

        if (alreadyLogged) {
            return;
        }

        CompletionLog log = CompletionLog.create(
                instance.getUserId(),
                instance.getTemplateId(),
                instance.getId(),
                instance.getCompletedAt() == null ? context.now() : instance.getCompletedAt(),
                instance.getAchievedDate() == null ? context.userToday() : instance.getAchievedDate(),
                result.actor()
        );

        completionLogRepository.save(log);
    }

    private void upsertSkipException(
            TaskInstance instance,
            String reason
    ) {
        TaskOccurrenceException exception = occurrenceExceptionRepository
                .findByTemplateIdAndOccurrenceDate(
                        instance.getTemplateId(),
                        instance.getOccurrenceDate()
                )
                .orElseGet(TaskOccurrenceException::new);

        exception.setUserId(instance.getUserId());
        exception.setTemplateId(instance.getTemplateId());
        exception.setTaskInstanceId(instance.getId());
        exception.setOccurrenceDate(instance.getOccurrenceDate());
        exception.setType(TaskOccurrenceExceptionType.SKIPPED);
        exception.setScope(TaskOccurrenceExceptionScope.THIS_OCCURRENCE);
        exception.setReason(reason);
        exception.markApplied();

        occurrenceExceptionRepository.save(exception);
    }

    private void upsertRescheduleException(
            TaskInstance instance,
            LocalDate targetScheduledDate,
            LocalDateTime targetDueDateTime,
            String reason
    ) {
        TaskOccurrenceException exception = occurrenceExceptionRepository
                .findByTemplateIdAndOccurrenceDate(
                        instance.getTemplateId(),
                        instance.getOccurrenceDate()
                )
                .orElseGet(TaskOccurrenceException::new);

        exception.setUserId(instance.getUserId());
        exception.setTemplateId(instance.getTemplateId());
        exception.setTaskInstanceId(instance.getId());
        exception.setOccurrenceDate(instance.getOccurrenceDate());
        exception.setType(TaskOccurrenceExceptionType.RESCHEDULED);
        exception.setScope(TaskOccurrenceExceptionScope.THIS_OCCURRENCE);
        exception.setRescheduledDate(targetScheduledDate);
        exception.setRescheduledDateTime(targetDueDateTime);
        exception.setReason(reason);
        exception.markApplied();

        occurrenceExceptionRepository.save(exception);
    }

    private TaskInstance findOwnedInstance(UUID userId, UUID taskInstanceId) {
        return taskInstanceRepository.findByIdForUser(userId, taskInstanceId)
                .orElseThrow(() -> new NotFoundException("Task instance not found"));
    }

    private TaskStateContext buildContext(UUID userId, String actor) {
        ZoneId zoneId = userTimeService.getUserZoneId(userId);

        return TaskStateContext.of(
                userId,
                zoneId,
                Instant.now(),
                actor
        );
    }

    public record TaskLifecycleResult(
            TaskInstance instance,
            TaskTransitionResult transitionResult,

            /**
             * Used by ROLLOVER.
             * Null for normal transitions.
             */
            TaskInstance createdTargetInstance,

            List<String> messages
    ) {
        public boolean hasCreatedTargetInstance() {
            return createdTargetInstance != null;
        }
    }
}