package com.lifeos.backend.task.infrastructure.scheduler;

import com.lifeos.backend.task.application.command.TaskLifecycleOrchestrator;
import com.lifeos.backend.task.application.policy.MissedPolicyResolver;
import com.lifeos.backend.task.application.query.OverdueTaskQueryService;
import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.entity.TaskTemplate;
import com.lifeos.backend.task.domain.repository.TaskTemplateRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Marks unfinished time-sensitive tasks as MISSED.
 *
 * MISSED means:
 * - the task/window is no longer valid
 * - different from SKIPPED
 * - different from OVERDUE
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class MissedTaskProcessor {

    private final OverdueTaskQueryService overdueTaskQueryService;
    private final MissedPolicyResolver missedPolicyResolver;
    private final TaskLifecycleOrchestrator lifecycleOrchestrator;
    private final TaskTemplateRepository taskTemplateRepository;

    /**
     * Usually called by MidnightRolloverEngine.
     *
     * targetDate = the day being finalized.
     *
     * Example:
     * At 2026-05-09 00:00, finalize 2026-05-08.
     */
    @Transactional
    public MissedTaskResult processForDayBoundary(
            UUID userId,
            LocalDate targetDate
    ) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }

        if (targetDate == null) {
            throw new IllegalArgumentException("targetDate is required");
        }

        LocalDate processingDay = targetDate.plusDays(1);
        LocalDateTime boundaryTime = processingDay.atStartOfDay();

        List<TaskInstance> candidates =
                overdueTaskQueryService.getOpenInstancesForDayBoundary(userId, targetDate);

        int scanned = 0;
        int markedMissed = 0;
        int skipped = 0;

        for (TaskInstance instance : candidates) {
            scanned++;

            TaskTemplate template = findTemplateOrNull(instance.getTemplateId());

            MissedPolicyResolver.MissedDecision decision =
                    missedPolicyResolver.evaluate(
                            instance,
                            template,
                            processingDay,
                            boundaryTime
                    );

            if (!decision.shouldMarkMissed()) {
                skipped++;
                continue;
            }

            try {
                lifecycleOrchestrator.markMissed(
                        userId,
                        instance.getId(),
                        "ENGINE",
                        decision.reason()
                );

                markedMissed++;

            } catch (Exception ex) {
                skipped++;
                log.error(
                        "Failed to mark task missed userId={} instanceId={}",
                        userId,
                        instance.getId(),
                        ex
                );
            }
        }

        return new MissedTaskResult(
                userId,
                targetDate,
                scanned,
                markedMissed,
                skipped
        );
    }

    private TaskTemplate findTemplateOrNull(UUID templateId) {
        if (templateId == null) {
            return null;
        }

        return taskTemplateRepository.findById(templateId).orElse(null);
    }

    public record MissedTaskResult(
            UUID userId,
            LocalDate targetDate,
            int scanned,
            int markedMissed,
            int skipped
    ) {
    }
}