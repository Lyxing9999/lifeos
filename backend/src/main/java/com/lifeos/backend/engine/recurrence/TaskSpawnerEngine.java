package com.lifeos.backend.engine.recurrence;

import com.lifeos.backend.task.application.command.TaskSpawnerService;
import com.lifeos.backend.task.application.command.TaskSpawnerService.TaskSpawnResult;
import com.lifeos.backend.user.domain.User;
import com.lifeos.backend.user.domain.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * System heartbeat for recurring task spawning.
 *
 * Responsibility:
 * - run on schedule
 * - loop users
 * - call TaskSpawnerService
 * - never allow one user failure to stop all users
 *
 * Important:
 * Actual SPAWN business logic belongs to TaskSpawnerService.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class TaskSpawnerEngine {

    private final TaskSpawnerService taskSpawnerService;
    private final UserRepository userRepository;

    @Value("${lifeos.engine.task-spawner.enabled:true}")
    private boolean enabled;

    /**
     * Runs every 30 minutes by default.
     *
     * You can override:
     * lifeos.engine.task-spawner.fixed-delay-ms=1800000
     */
    @Scheduled(fixedDelayString = "${lifeos.engine.task-spawner.fixed-delay-ms:1800000}")
    public void run() {
        if (!enabled) {
            log.debug("TaskSpawnerEngine skipped because it is disabled");
            return;
        }

        List<User> users = userRepository.findAll();

        if (users.isEmpty()) {
            log.debug("TaskSpawnerEngine found no users");
            return;
        }

        log.info("TaskSpawnerEngine started for {} user(s)", users.size());

        int successCount = 0;
        int failureCount = 0;
        int totalInstancesCreated = 0;

        for (User user : users) {
            if (user == null || user.getId() == null) {
                continue;
            }

            try {
                TaskSpawnResult result = taskSpawnerService.spawnDefaultWindow(user.getId());

                successCount++;
                totalInstancesCreated += result.instancesCreated();

                log.debug(
                        "TaskSpawnerEngine user={} templatesScanned={} instancesCreated={} skippedByException={} ignoredExisting={}",
                        user.getId(),
                        result.templatesScanned(),
                        result.instancesCreated(),
                        result.skippedByException(),
                        result.ignoredExisting()
                );

            } catch (Exception ex) {
                failureCount++;

                log.error(
                        "TaskSpawnerEngine failed for user={}",
                        user.getId(),
                        ex
                );
            }
        }

        log.info(
                "TaskSpawnerEngine finished successCount={} failureCount={} totalInstancesCreated={}",
                successCount,
                failureCount,
                totalInstancesCreated
        );
    }
}