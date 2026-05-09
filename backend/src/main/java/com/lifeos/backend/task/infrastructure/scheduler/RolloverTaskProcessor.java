package com.lifeos.backend.task.infrastructure.scheduler;

import com.lifeos.backend.task.application.command.TaskLifecycleOrchestrator;
import com.lifeos.backend.task.application.policy.RolloverPolicyResolver;
import com.lifeos.backend.task.application.query.OverdueTaskQueryService;
import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.entity.TaskTemplate;
import com.lifeos.backend.task.domain.repository.TaskTemplateRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/**
 * Rolls unfinished work into a new target date.
 *
 * ROLLOVER means:
 * - old instance becomes ROLLED_OVER
 * - new target instance is created by TaskLifecycleOrchestrator
 * - old history is preserved
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class RolloverTaskProcessor {

    private final OverdueTaskQueryService overdueTaskQueryService;
    private final RolloverPolicyResolver rolloverPolicyResolver;
    private final TaskLifecycleOrchestrator lifecycleOrchestrator;
    private final TaskTemplateRepository taskTemplateRepository;

    /**
     * Usually called by MidnightRolloverEngine.
     *
     * targetDate = the day being finalized.
     *
     * Example:
     * At 2026-05-09 00:00, finalize 2026-05-08.
     * ROLLOVER_TO_NEXT_DAY should move unfinished work to 2026-05-09.
     */
    @Transactional
    public RolloverTaskResult processForDayBoundary(
            UUID userId,
            LocalDate targetDate
    ) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }

        if (targetDate == null) {
            throw new IllegalArgumentException("targetDate is required");
        }

        List<TaskInstance> candidates =
                overdueTaskQueryService.getOpenInstancesForDayBoundary(userId, targetDate);

        int scanned = 0;
        int rolledOver = 0;
        int skipped = 0;

        for (TaskInstance instance : candidates) {
            scanned++;

            TaskTemplate template = findTemplateOrNull(instance.getTemplateId());

            RolloverPolicyResolver.RolloverDecision decision =
                    rolloverPolicyResolver.evaluate(
                            instance,
                            template,
                            targetDate
                    );

            if (!decision.shouldRollover()) {
                skipped++;
                continue;
            }

            try {
                lifecycleOrchestrator.rollover(
                        userId,
                        instance.getId(),
                        decision.targetScheduledDate(),
                        decision.targetDueDateTime(),
                        "ENGINE",
                        decision.reason()
                );

                rolledOver++;

            } catch (Exception ex) {
                skipped++;
                log.error(
                        "Failed to rollover task userId={} instanceId={}",
                        userId,
                        instance.getId(),
                        ex
                );
            }
        }

        return new RolloverTaskResult(
                userId,
                targetDate,
                scanned,
                rolledOver,
                skipped
        );
    }

    private TaskTemplate findTemplateOrNull(UUID templateId) {
        if (templateId == null) {
            return null;
        }

        return taskTemplateRepository.findById(templateId).orElse(null);
    }

    public record RolloverTaskResult(
            UUID userId,
            LocalDate targetDate,
            int scanned,
            int rolledOver,
            int skipped
    ) {
    }
}