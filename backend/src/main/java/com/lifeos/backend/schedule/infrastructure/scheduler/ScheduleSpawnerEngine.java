package com.lifeos.backend.schedule.infrastructure.scheduler;

import com.lifeos.backend.schedule.application.command.ScheduleSpawnerService;
import com.lifeos.backend.schedule.application.command.ScheduleSpawnerService.ScheduleSpawnResult;
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
 * Schedule heartbeat for spawning ScheduleOccurrence rows.
 *
 * ScheduleSpawnerEngine belongs inside schedule/infrastructure/scheduler
 * because it only touches Schedule data.
 *
 * Responsibility:
 * - loop users
 * - call ScheduleSpawnerService
 * - create future planned schedule occurrences
 *
 * It does NOT:
 * - build Today screen
 * - build Timeline
 * - complete tasks
 * - decide task lifecycle
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ScheduleSpawnerEngine {

    private final UserRepository userRepository;
    private final ScheduleSpawnerService scheduleSpawnerService;

    @Value("${lifeos.schedule.scheduler.spawner.enabled:true}")
    private boolean enabled;

    /**
     * Runs every 30 minutes by default.
     *
     * The spawner is idempotent because ScheduleSpawnerService checks existing
     * templateId + occurrenceDate before saving.
     */
    @Scheduled(fixedDelayString = "${lifeos.schedule.scheduler.spawner.fixed-delay-ms:1800000}")
    public void run() {
        if (!enabled) {
            log.debug("ScheduleSpawnerEngine skipped because it is disabled");
            return;
        }

        runForAllUsers();
    }

    /**
     * Manual/admin/test trigger.
     */
    public ScheduleSpawnerEngineResult runForAllUsers() {
        List<User> users = userRepository.findAll();

        int scannedUsers = 0;
        int successUsers = 0;
        int failedUsers = 0;

        int totalTemplatesScanned = 0;
        int totalOccurrencesCreated = 0;
        int totalSkippedByException = 0;
        int totalCancelledByException = 0;
        int totalIgnoredExisting = 0;
        int totalRescheduled = 0;

        for (User user : users) {
            if (user == null || user.getId() == null) {
                continue;
            }

            scannedUsers++;

            try {
                ScheduleSpawnResult result =
                        scheduleSpawnerService.spawnDefaultWindow(user.getId());

                successUsers++;

                totalTemplatesScanned += result.templatesScanned();
                totalOccurrencesCreated += result.occurrencesCreated();
                totalSkippedByException += result.skippedByException();
                totalCancelledByException += result.cancelledByException();
                totalIgnoredExisting += result.ignoredExisting();
                totalRescheduled += result.rescheduled();

                log.debug(
                        "ScheduleSpawnerEngine user={} templatesScanned={} occurrencesCreated={} skippedByException={} cancelledByException={} ignoredExisting={} rescheduled={}",
                        user.getId(),
                        result.templatesScanned(),
                        result.occurrencesCreated(),
                        result.skippedByException(),
                        result.cancelledByException(),
                        result.ignoredExisting(),
                        result.rescheduled()
                );

            } catch (Exception ex) {
                failedUsers++;

                log.error(
                        "ScheduleSpawnerEngine failed for user={}",
                        user.getId(),
                        ex
                );
            }
        }

        ScheduleSpawnerEngineResult result = new ScheduleSpawnerEngineResult(
                scannedUsers,
                successUsers,
                failedUsers,
                totalTemplatesScanned,
                totalOccurrencesCreated,
                totalSkippedByException,
                totalCancelledByException,
                totalIgnoredExisting,
                totalRescheduled
        );

        log.info(
                "ScheduleSpawnerEngine finished scannedUsers={} successUsers={} failedUsers={} occurrencesCreated={}",
                result.scannedUsers(),
                result.successUsers(),
                result.failedUsers(),
                result.totalOccurrencesCreated()
        );

        return result;
    }

    /**
     * Manual/admin/test trigger for one user.
     */
    public ScheduleSpawnResult runForUser(UUID userId) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }

        return scheduleSpawnerService.spawnDefaultWindow(userId);
    }

    /**
     * Manual/admin/test trigger for one user with custom window.
     */
    public ScheduleSpawnResult runWindowForUser(
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

        return scheduleSpawnerService.spawnWindow(
                userId,
                windowStart,
                windowEnd
        );
    }

    public record ScheduleSpawnerEngineResult(
            int scannedUsers,
            int successUsers,
            int failedUsers,
            int totalTemplatesScanned,
            int totalOccurrencesCreated,
            int totalSkippedByException,
            int totalCancelledByException,
            int totalIgnoredExisting,
            int totalRescheduled
    ) {
    }
}