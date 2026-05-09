package com.lifeos.backend.schedule.infrastructure.scheduler;

import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.schedule.application.policy.ScheduleExpirationPolicy;
import com.lifeos.backend.schedule.application.policy.ScheduleExpirationPolicy.TimeStateDecision;
import com.lifeos.backend.schedule.domain.entity.ScheduleOccurrence;
import com.lifeos.backend.schedule.domain.enums.ScheduleOccurrenceStatus;
import com.lifeos.backend.schedule.domain.repository.ScheduleOccurrenceRepository;
import com.lifeos.backend.schedule.domain.service.ScheduleOccurrenceLifecycleService;
import com.lifeos.backend.schedule.infrastructure.event.ScheduleDomainEventPublisher;
import com.lifeos.backend.user.domain.User;
import com.lifeos.backend.user.domain.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Keeps ScheduleOccurrence time-state updated.
 *
 * Handles:
 * - PLANNED -> ACTIVE
 * - PLANNED/ACTIVE -> EXPIRED
 *
 * Important:
 * Schedule does not mean "completed".
 * EXPIRED only means the time block ended.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ScheduleLifecycleWorker {

    private final UserRepository userRepository;
    private final UserTimeService userTimeService;

    private final ScheduleOccurrenceRepository occurrenceRepository;
    private final ScheduleOccurrenceLifecycleService lifecycleService;
    private final ScheduleExpirationPolicy expirationPolicy;
    private final ScheduleDomainEventPublisher scheduleDomainEventPublisher;

    @Value("${lifeos.schedule.scheduler.lifecycle.enabled:true}")
    private boolean enabled;

    /**
     * Runs every 5 minutes by default.
     */
    @Scheduled(fixedDelayString = "${lifeos.schedule.scheduler.lifecycle.fixed-delay-ms:300000}")
    public void run() {
        if (!enabled) {
            log.debug("ScheduleLifecycleWorker skipped because it is disabled");
            return;
        }

        runForAllUsers();
    }

    /**
     * Manual/admin/test trigger.
     */
    @Transactional
    public ScheduleLifecycleWorkerResult runForAllUsers() {
        List<User> users = userRepository.findAll();

        int scannedUsers = 0;
        int successUsers = 0;
        int failedUsers = 0;
        int totalActivated = 0;
        int totalExpired = 0;
        int totalSkipped = 0;

        for (User user : users) {
            if (user == null || user.getId() == null) {
                continue;
            }

            scannedUsers++;

            try {
                ScheduleLifecycleUserResult userResult = runForUser(user.getId());

                successUsers++;
                totalActivated += userResult.activated();
                totalExpired += userResult.expired();
                totalSkipped += userResult.skipped();

            } catch (Exception ex) {
                failedUsers++;

                log.error(
                        "ScheduleLifecycleWorker failed for user={}",
                        user.getId(),
                        ex
                );
            }
        }

        ScheduleLifecycleWorkerResult result = new ScheduleLifecycleWorkerResult(
                scannedUsers,
                successUsers,
                failedUsers,
                totalActivated,
                totalExpired,
                totalSkipped
        );

        log.info(
                "ScheduleLifecycleWorker finished scannedUsers={} successUsers={} failedUsers={} activated={} expired={}",
                result.scannedUsers(),
                result.successUsers(),
                result.failedUsers(),
                result.totalActivated(),
                result.totalExpired()
        );

        return result;
    }

    /**
     * Manual/admin/test trigger for one user.
     */
    @Transactional
    public ScheduleLifecycleUserResult runForUser(UUID userId) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }

        LocalDateTime userNowLocal = resolveUserNowLocal(userId);

        int activated = activateCurrentOccurrences(userId, userNowLocal);
        int expired = expirePastOccurrences(userId, userNowLocal);

        return new ScheduleLifecycleUserResult(
                userId,
                userNowLocal,
                activated,
                expired,
                0
        );
    }

    private int activateCurrentOccurrences(
            UUID userId,
            LocalDateTime userNowLocal
    ) {
        List<ScheduleOccurrence> candidates =
                occurrenceRepository.findOccurrencesActiveAt(
                        userId,
                        userNowLocal,
                        List.of(ScheduleOccurrenceStatus.PLANNED)
                );

        int activated = 0;

        for (ScheduleOccurrence occurrence : candidates) {
            TimeStateDecision decision = expirationPolicy.evaluate(
                    occurrence,
                    userNowLocal
            );

            if (!decision.shouldActivate()) {
                continue;
            }

            try {
                lifecycleService.activate(occurrence, Instant.now());
                ScheduleOccurrence saved = occurrenceRepository.save(occurrence);
                scheduleDomainEventPublisher.publishActivated(saved);
                activated++;

            } catch (Exception ex) {
                log.error(
                        "Failed to activate schedule occurrence userId={} occurrenceId={}",
                        userId,
                        occurrence.getId(),
                        ex
                );
            }
        }

        return activated;
    }

    private int expirePastOccurrences(
            UUID userId,
            LocalDateTime userNowLocal
    ) {
        List<ScheduleOccurrence> candidates =
                occurrenceRepository.findOpenOccurrencesBefore(
                        userId,
                        userNowLocal,
                        List.of(
                                ScheduleOccurrenceStatus.PLANNED,
                                ScheduleOccurrenceStatus.ACTIVE
                        )
                );

        int expired = 0;

        for (ScheduleOccurrence occurrence : candidates) {
            TimeStateDecision decision = expirationPolicy.evaluate(
                    occurrence,
                    userNowLocal
            );

            if (!decision.shouldExpire()) {
                continue;
            }

            try {
                lifecycleService.expire(occurrence, Instant.now());
                ScheduleOccurrence saved = occurrenceRepository.save(occurrence);
                expired++;
                scheduleDomainEventPublisher.publishActivated(saved);
            } catch (Exception ex) {
                log.error(
                        "Failed to expire schedule occurrence userId={} occurrenceId={}",
                        userId,
                        occurrence.getId(),
                        ex
                );
            }
        }

        return expired;
    }

    private LocalDateTime resolveUserNowLocal(UUID userId) {
        return Instant.now()
                .atZone(userTimeService.getUserZoneId(userId))
                .toLocalDateTime();
    }

    public record ScheduleLifecycleWorkerResult(
            int scannedUsers,
            int successUsers,
            int failedUsers,
            int totalActivated,
            int totalExpired,
            int totalSkipped
    ) {
    }

    public record ScheduleLifecycleUserResult(
            UUID userId,
            LocalDateTime userNowLocal,
            int activated,
            int expired,
            int skipped
    ) {
    }
}