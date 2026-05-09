package com.lifeos.backend.task.application.command;

import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.task.application.command.TaskLifecycleOrchestrator.TaskLifecycleResult;
import com.lifeos.backend.task.domain.entity.CompletionLog;
import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.task.domain.repository.CompletionLogRepository;
import com.lifeos.backend.task.domain.repository.TaskInstanceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

/**
 * Application service for completion-related use cases.
 *
 * This service does not directly mutate lifecycle fields.
 * It delegates lifecycle transitions to TaskLifecycleOrchestrator.
 */
@Service
@RequiredArgsConstructor
public class TaskCompletionService {

    private final TaskLifecycleOrchestrator lifecycleOrchestrator;
    private final CompletionLogRepository completionLogRepository;
    private final TaskInstanceRepository taskInstanceRepository;
    private final UserTimeService userTimeService;

    @Transactional
    public TaskLifecycleResult complete(
            UUID userId,
            UUID taskInstanceId
    ) {
        return lifecycleOrchestrator.complete(userId, taskInstanceId);
    }

    @Transactional
    public TaskLifecycleResult reopen(
            UUID userId,
            UUID taskInstanceId,
            String reason
    ) {
        return lifecycleOrchestrator.reopen(userId, taskInstanceId, reason);
    }

    @Transactional
    public TaskLifecycleResult clearFromDone(
            UUID userId,
            UUID taskInstanceId
    ) {
        return lifecycleOrchestrator.clearFromDone(userId, taskInstanceId);
    }

    @Transactional
    public TaskLifecycleResult restoreToDone(
            UUID userId,
            UUID taskInstanceId
    ) {
        return lifecycleOrchestrator.restoreToDone(userId, taskInstanceId);
    }

    /**
     * Hide all completed tasks from Done view for one user-local date.
     *
     * Important:
     * This does NOT delete history.
     * This does NOT remove CompletionLog.
     * This only sets doneClearedAt on completed instances.
     */
    @Transactional
    public DoneCleanupResult clearDoneForDay(
            UUID userId,
            LocalDate date
    ) {
        LocalDate targetDate = resolveUserDate(userId, date);

        List<CompletionLog> logs = completionLogRepository
                .findByUserIdAndAchievedDate(userId, targetDate);

        Set<UUID> instanceIds = uniqueInstanceIds(logs);

        int cleared = 0;
        int skipped = 0;

        for (UUID instanceId : instanceIds) {
            TaskInstance instance = taskInstanceRepository
                    .findByIdForUser(userId, instanceId)
                    .orElse(null);

            if (instance == null) {
                skipped++;
                continue;
            }

            if (instance.getStatus() != TaskInstanceStatus.COMPLETED) {
                skipped++;
                continue;
            }

            if (instance.getDoneClearedAt() != null) {
                skipped++;
                continue;
            }

            lifecycleOrchestrator.clearFromDone(userId, instanceId);
            cleared++;
        }

        return new DoneCleanupResult(
                userId,
                targetDate,
                instanceIds.size(),
                cleared,
                skipped
        );
    }

    /**
     * Restore all cleared Done items for one user-local date.
     */
    @Transactional
    public DoneCleanupResult restoreDoneForDay(
            UUID userId,
            LocalDate date
    ) {
        LocalDate targetDate = resolveUserDate(userId, date);

        List<CompletionLog> logs = completionLogRepository
                .findByUserIdAndAchievedDate(userId, targetDate);

        Set<UUID> instanceIds = uniqueInstanceIds(logs);

        int restored = 0;
        int skipped = 0;

        for (UUID instanceId : instanceIds) {
            TaskInstance instance = taskInstanceRepository
                    .findByIdForUser(userId, instanceId)
                    .orElse(null);

            if (instance == null) {
                skipped++;
                continue;
            }

            if (instance.getStatus() != TaskInstanceStatus.COMPLETED) {
                skipped++;
                continue;
            }

            if (instance.getDoneClearedAt() == null) {
                skipped++;
                continue;
            }

            lifecycleOrchestrator.restoreToDone(userId, instanceId);
            restored++;
        }

        return new DoneCleanupResult(
                userId,
                targetDate,
                instanceIds.size(),
                restored,
                skipped
        );
    }

    private LocalDate resolveUserDate(UUID userId, LocalDate date) {
        if (date != null) {
            return date;
        }

        return Instant.now()
                .atZone(userTimeService.getUserZoneId(userId))
                .toLocalDate();
    }

    private Set<UUID> uniqueInstanceIds(List<CompletionLog> logs) {
        Set<UUID> ids = new LinkedHashSet<>();

        if (logs == null) {
            return ids;
        }

        logs.stream()
                .map(CompletionLog::getTaskInstanceId)
                .filter(java.util.Objects::nonNull)
                .forEach(ids::add);

        return ids;
    }

    public record DoneCleanupResult(
            UUID userId,
            LocalDate date,
            int scanned,
            int changed,
            int skipped
    ) {
    }
}