package com.lifeos.backend.task.infrastructure.scheduler;

import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.task.infrastructure.scheduler.MissedTaskProcessor.MissedTaskResult;
import com.lifeos.backend.task.infrastructure.scheduler.OverdueSweepProcessor.OverdueSweepResult;
import com.lifeos.backend.task.infrastructure.scheduler.RolloverTaskProcessor.RolloverTaskResult;
import com.lifeos.backend.user.domain.User;
import com.lifeos.backend.user.domain.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;

/**
 * Midnight lifecycle engine.
 *
 * Finalizes the user's previous local day:
 * - MISSED for time-sensitive tasks
 * - ROLLOVER for carryable tasks
 * - OVERDUE for still-actionable late tasks
 *
 * Order matters:
 * 1. MISSED
 * 2. ROLLOVER
 * 3. OVERDUE
 *
 * Configure flexible tasks with:
 * - missedPolicy = NEVER_MISS
 * - rolloverPolicy = ROLLOVER_TO_NEXT_DAY or KEEP_OVERDUE
 *
 * Configure strict tasks with:
 * - missedPolicy = MISS_AFTER_DUE_TIME or MISS_AT_END_OF_DAY
 * - rolloverPolicy = DO_NOT_ROLLOVER
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class MidnightRolloverEngine {

    private final UserRepository userRepository;
    private final UserTimeService userTimeService;

    private final MissedTaskProcessor missedTaskProcessor;
    private final RolloverTaskProcessor rolloverTaskProcessor;
    private final OverdueSweepProcessor overdueSweepProcessor;

    @Value("${lifeos.engine.midnight-rollover.enabled:true}")
    private boolean enabled;

    /**
     * Runs every 15 minutes.
     *
     * Why not only at 00:00 server time?
     * Because every user has their own timezone.
     *
     * This checks if each user's local time is near midnight.
     */
    @Scheduled(fixedDelayString = "${lifeos.engine.midnight-rollover.fixed-delay-ms:900000}")
    public void run() {
        if (!enabled) {
            log.debug("MidnightRolloverEngine skipped because it is disabled");
            return;
        }

        List<User> users = userRepository.findAll();

        if (users.isEmpty()) {
            log.debug("MidnightRolloverEngine found no users");
            return;
        }

        int processedUsers = 0;
        int skippedUsers = 0;
        int failedUsers = 0;

        for (User user : users) {
            if (user == null || user.getId() == null) {
                skippedUsers++;
                continue;
            }

            if (!isNearUserMidnight(user)) {
                skippedUsers++;
                continue;
            }

            try {
                LocalDate targetDate = resolveTargetDate(user);

                processUser(user, targetDate);
                processedUsers++;

            } catch (Exception ex) {
                failedUsers++;

                log.error(
                        "MidnightRolloverEngine failed for user={}",
                        user.getId(),
                        ex
                );
            }
        }

        log.info(
                "MidnightRolloverEngine finished processedUsers={} skippedUsers={} failedUsers={}",
                processedUsers,
                skippedUsers,
                failedUsers
        );
    }

    /**
     * Manual trigger for tests/admin/debug.
     */
    public MidnightRolloverResult runForUserNow(User user) {
        if (user == null || user.getId() == null) {
            throw new IllegalArgumentException("user is required");
        }

        LocalDate targetDate = resolveTargetDate(user);
        return processUser(user, targetDate);
    }

    /**
     * Manual trigger with explicit targetDate.
     */
    public MidnightRolloverResult runForUserAndDate(
            User user,
            LocalDate targetDate
    ) {
        if (user == null || user.getId() == null) {
            throw new IllegalArgumentException("user is required");
        }

        if (targetDate == null) {
            throw new IllegalArgumentException("targetDate is required");
        }

        return processUser(user, targetDate);
    }

    private MidnightRolloverResult processUser(User user, LocalDate targetDate) {
        MissedTaskResult missedResult =
                missedTaskProcessor.processForDayBoundary(user.getId(), targetDate);

        RolloverTaskResult rolloverResult =
                rolloverTaskProcessor.processForDayBoundary(user.getId(), targetDate);

        OverdueSweepResult overdueResult =
                overdueSweepProcessor.processNow(user.getId());

        log.info(
                "Midnight finalized user={} targetDate={} missed={} rolledOver={} overdue={}",
                user.getId(),
                targetDate,
                missedResult.markedMissed(),
                rolloverResult.rolledOver(),
                overdueResult.markedOverdue()
        );

        return new MidnightRolloverResult(
                user.getId(),
                targetDate,
                missedResult,
                rolloverResult,
                overdueResult
        );
    }

    private boolean isNearUserMidnight(User user) {
        int hour = Instant.now()
                .atZone(userTimeService.getUserZoneId(user.getId()))
                .getHour();

        int minute = Instant.now()
                .atZone(userTimeService.getUserZoneId(user.getId()))
                .getMinute();

        /**
         * Runs only from 00:00 to 00:29 local time.
         *
         * Since scheduler runs every 15 minutes, this should catch each user.
         */
        return hour == 0 && minute < 30;
    }

    private LocalDate resolveTargetDate(User user) {
        return Instant.now()
                .atZone(userTimeService.getUserZoneId(user.getId()))
                .toLocalDate()
                .minusDays(1);
    }

    public record MidnightRolloverResult(
            java.util.UUID userId,
            LocalDate targetDate,
            MissedTaskResult missedResult,
            RolloverTaskResult rolloverResult,
            OverdueSweepResult overdueResult
    ) {
    }
}