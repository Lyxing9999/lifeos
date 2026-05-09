package com.lifeos.backend.task.infrastructure.scheduler;

import com.lifeos.backend.task.application.command.TaskSpawnerService;
import com.lifeos.backend.task.application.command.TaskSpawnerService.TaskSpawnResult;
import com.lifeos.backend.user.domain.User;
import com.lifeos.backend.user.domain.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/**
 * Task module scheduled worker.
 *
 * This is a thin infrastructure adapter for task-related scheduled work.
 *
 * Important architecture rule:
 * - Real system heartbeat belongs to engine/*
 * - This worker should delegate to task application services
 * - Do not put lifecycle business rules here
 *
 * If you already use engine/recurrence/TaskSpawnerEngine,
 * keep this worker disabled to avoid duplicated scheduler responsibility.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class TaskScheduledWorker {

    private final UserRepository userRepository;
    private final TaskSpawnerService taskSpawnerService;

    /**
     * Disabled by default because TaskSpawnerEngine already exists.
     *
     * Enable only if you want task module to run its own spawn worker:
     * lifeos.task.scheduled-worker.enabled=true
     */
    @Value("${lifeos.task.scheduled-worker.enabled:false}")
    private boolean enabled;

    /**
     * Optional recurring task spawn worker.
     *
     * Default fixed delay: 30 minutes.
     */
    @Scheduled(fixedDelayString = "${lifeos.task.scheduled-worker.spawn-fixed-delay-ms:1800000}")
    public void spawnRecurringTaskInstances() {
        if (!enabled) {
            log.debug("TaskScheduledWorker skipped because it is disabled");
            return;
        }

        runSpawnForAllUsers();
    }

    /**
     * Manual/admin/test trigger.
     */
    public TaskScheduledWorkerResult runSpawnForAllUsers() {
        List<User> users = userRepository.findAll();

        int scannedUsers = 0;
        int successUsers = 0;
        int failedUsers = 0;
        int totalTemplatesScanned = 0;
        int totalInstancesCreated = 0;
        int totalSkippedByException = 0;
        int totalIgnoredExisting = 0;

        for (User user : users) {
            if (user == null || user.getId() == null) {
                continue;
            }

            scannedUsers++;

            try {
                TaskSpawnResult result = taskSpawnerService.spawnDefaultWindow(user.getId());

                successUsers++;
                totalTemplatesScanned += result.templatesScanned();
                totalInstancesCreated += result.instancesCreated();
                totalSkippedByException += result.skippedByException();
                totalIgnoredExisting += result.ignoredExisting();

                log.debug(
                        "TaskScheduledWorker spawned for user={} templatesScanned={} instancesCreated={} skippedByException={} ignoredExisting={}",
                        user.getId(),
                        result.templatesScanned(),
                        result.instancesCreated(),
                        result.skippedByException(),
                        result.ignoredExisting()
                );

            } catch (Exception ex) {
                failedUsers++;

                log.error(
                        "TaskScheduledWorker failed to spawn recurring task instances for user={}",
                        user.getId(),
                        ex
                );
            }
        }

        TaskScheduledWorkerResult result = new TaskScheduledWorkerResult(
                scannedUsers,
                successUsers,
                failedUsers,
                totalTemplatesScanned,
                totalInstancesCreated,
                totalSkippedByException,
                totalIgnoredExisting
        );

        log.info(
                "TaskScheduledWorker finished scannedUsers={} successUsers={} failedUsers={} totalInstancesCreated={}",
                result.scannedUsers(),
                result.successUsers(),
                result.failedUsers(),
                result.totalInstancesCreated()
        );

        return result;
    }

    /**
     * Manual/admin/test trigger for one user.
     */
    public TaskSpawnResult runSpawnForUser(UUID userId) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }

        return taskSpawnerService.spawnDefaultWindow(userId);
    }

    /**
     * Manual/admin/test trigger for one user and custom window.
     */
    public TaskSpawnResult runSpawnWindowForUser(
            UUID userId,
            LocalDate windowStart,
            LocalDate windowEnd
    ) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }

        if (windowStart == null) {
            throw new IllegalArgumentException("windowStart is required");
        }

        if (windowEnd == null) {
            throw new IllegalArgumentException("windowEnd is required");
        }

        if (windowEnd.isBefore(windowStart)) {
            throw new IllegalArgumentException("windowEnd must be on or after windowStart");
        }

        return taskSpawnerService.spawnWindow(
                userId,
                windowStart,
                windowEnd
        );
    }

    public record TaskScheduledWorkerResult(
            int scannedUsers,
            int successUsers,
            int failedUsers,
            int totalTemplatesScanned,
            int totalInstancesCreated,
            int totalSkippedByException,
            int totalIgnoredExisting
    ) {
    }
}