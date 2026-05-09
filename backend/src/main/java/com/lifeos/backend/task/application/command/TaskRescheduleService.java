package com.lifeos.backend.task.application.command;

import com.lifeos.backend.common.exception.NotFoundException;
import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.task.application.command.TaskLifecycleOrchestrator.TaskLifecycleResult;
import com.lifeos.backend.task.domain.entity.MutationHistory;
import com.lifeos.backend.task.domain.entity.TaskOccurrenceException;
import com.lifeos.backend.task.domain.entity.TaskTemplate;
import com.lifeos.backend.task.domain.enums.MutationType;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.task.domain.enums.TaskOccurrenceExceptionScope;
import com.lifeos.backend.task.domain.enums.TaskOccurrenceExceptionType;
import com.lifeos.backend.task.domain.enums.TaskTransitionType;
import com.lifeos.backend.task.domain.repository.MutationHistoryRepository;
import com.lifeos.backend.task.domain.repository.TaskOccurrenceExceptionRepository;
import com.lifeos.backend.task.domain.repository.TaskTemplateRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Application service for rescheduling.
 *
 * Existing instance:
 * - delegate to TaskLifecycleOrchestrator
 *
 * Future recurring occurrence before spawn:
 * - create TaskOccurrenceException(type = RESCHEDULED)
 */
@Service
@RequiredArgsConstructor
public class TaskRescheduleService {

    private final TaskLifecycleOrchestrator lifecycleOrchestrator;
    private final TaskTemplateRepository taskTemplateRepository;
    private final TaskOccurrenceExceptionRepository occurrenceExceptionRepository;
    private final MutationHistoryRepository mutationHistoryRepository;
    private final UserTimeService userTimeService;

    /**
     * Reschedule an existing TaskInstance.
     */
    @Transactional
    public TaskLifecycleResult rescheduleInstance(
            UUID userId,
            UUID taskInstanceId,
            LocalDate targetScheduledDate,
            LocalDateTime targetDueDateTime,
            String reason
    ) {
        validateTarget(targetScheduledDate, targetDueDateTime);

        return lifecycleOrchestrator.reschedule(
                userId,
                taskInstanceId,
                targetScheduledDate,
                targetDueDateTime,
                reason
        );
    }

    /**
     * Reschedule a recurring occurrence before its TaskInstance exists.
     *
     * Example:
     * Template repeats daily.
     * User reschedules tomorrow's occurrence before spawner creates it.
     *
     * The spawner will read this exception and create the instance
     * at the rescheduled date/time.
     */
    @Transactional
    public TaskOccurrenceException rescheduleFutureOccurrence(
            UUID userId,
            UUID templateId,
            LocalDate occurrenceDate,
            LocalDate targetScheduledDate,
            LocalDateTime targetDueDateTime,
            String reason
    ) {
        validateUserId(userId);
        validateTemplateOwnership(userId, templateId);
        validateOccurrenceDate(occurrenceDate);
        validateTarget(targetScheduledDate, targetDueDateTime);

        LocalDate resolvedTargetDate = resolveTargetDate(
                targetScheduledDate,
                targetDueDateTime
        );

        TaskOccurrenceException exception = occurrenceExceptionRepository
                .findByTemplateIdAndOccurrenceDate(templateId, occurrenceDate)
                .orElseGet(TaskOccurrenceException::new);

        exception.setUserId(userId);
        exception.setTemplateId(templateId);
        exception.setOccurrenceDate(occurrenceDate);
        exception.setType(TaskOccurrenceExceptionType.RESCHEDULED);
        exception.setScope(TaskOccurrenceExceptionScope.THIS_OCCURRENCE);
        exception.setRescheduledDate(resolvedTargetDate);
        exception.setRescheduledDateTime(targetDueDateTime);
        exception.setReason(reason);
        exception.markApplied();

        TaskOccurrenceException saved = occurrenceExceptionRepository.save(exception);

        mutationHistoryRepository.save(
                MutationHistory.lifecycle(
                        userId,
                        templateId,
                        null,
                        MutationType.INSTANCE_RESCHEDULED,
                        TaskTransitionType.RESCHEDULE,
                        null,
                        resolveStatusForTargetDate(userId, resolvedTargetDate),
                        "USER",
                        reason
                )
        );

        return saved;
    }

    private void validateTarget(
            LocalDate targetScheduledDate,
            LocalDateTime targetDueDateTime
    ) {
        if (targetScheduledDate == null && targetDueDateTime == null) {
            throw new IllegalArgumentException(
                    "targetScheduledDate or targetDueDateTime is required"
            );
        }
    }

    private LocalDate resolveTargetDate(
            LocalDate targetScheduledDate,
            LocalDateTime targetDueDateTime
    ) {
        if (targetScheduledDate != null) {
            return targetScheduledDate;
        }

        return targetDueDateTime.toLocalDate();
    }

    private TaskInstanceStatus resolveStatusForTargetDate(
            UUID userId,
            LocalDate targetDate
    ) {
        LocalDate today = Instant.now()
                .atZone(userTimeService.getUserZoneId(userId))
                .toLocalDate();

        if (targetDate == null) {
            return TaskInstanceStatus.INBOX;
        }

        if (targetDate.isBefore(today)) {
            return TaskInstanceStatus.OVERDUE;
        }

        if (targetDate.equals(today)) {
            return TaskInstanceStatus.DUE_TODAY;
        }

        return TaskInstanceStatus.SCHEDULED;
    }

    private void validateUserId(UUID userId) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }
    }

    private void validateTemplateOwnership(UUID userId, UUID templateId) {
        if (templateId == null) {
            throw new IllegalArgumentException("templateId is required");
        }

        TaskTemplate template = taskTemplateRepository
                .findByIdForUser(userId, templateId)
                .orElseThrow(() -> new NotFoundException("Task template not found"));

        if (!template.isRecurring()) {
            throw new IllegalArgumentException(
                    "Only recurring task template occurrences can be rescheduled before spawn"
            );
        }
    }

    private void validateOccurrenceDate(LocalDate occurrenceDate) {
        if (occurrenceDate == null) {
            throw new IllegalArgumentException("occurrenceDate is required");
        }
    }
}