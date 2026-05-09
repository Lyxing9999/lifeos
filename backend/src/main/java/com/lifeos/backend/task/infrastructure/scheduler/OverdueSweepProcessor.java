package com.lifeos.backend.task.infrastructure.scheduler;

import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.task.application.command.TaskLifecycleOrchestrator;
import com.lifeos.backend.task.application.policy.OverduePolicyResolver;
import com.lifeos.backend.task.application.query.OverdueTaskQueryService;
import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.entity.TaskTemplate;
import com.lifeos.backend.task.domain.repository.TaskTemplateRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Finds open tasks that should become OVERDUE.
 *
 * This processor does not decide by itself.
 * It asks OverduePolicyResolver.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class OverdueSweepProcessor {

    private final OverdueTaskQueryService overdueTaskQueryService;
    private final OverduePolicyResolver overduePolicyResolver;
    private final TaskLifecycleOrchestrator lifecycleOrchestrator;
    private final TaskTemplateRepository taskTemplateRepository;
    private final UserTimeService userTimeService;

    @Transactional
    public OverdueSweepResult processNow(UUID userId) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }

        LocalDate userToday = resolveUserToday(userId);
        LocalDateTime userNow = resolveUserNow(userId);

        List<TaskInstance> candidates = overdueTaskQueryService.getOverdueCandidatesNow(userId);

        int scanned = 0;
        int markedOverdue = 0;
        int skipped = 0;

        for (TaskInstance instance : candidates) {
            scanned++;

            TaskTemplate template = findTemplateOrNull(instance.getTemplateId());

            OverduePolicyResolver.OverdueDecision decision =
                    overduePolicyResolver.evaluate(
                            instance,
                            template,
                            userToday,
                            userNow
                    );

            if (!decision.shouldMarkOverdue()) {
                skipped++;
                continue;
            }

            try {
                lifecycleOrchestrator.markOverdue(
                        userId,
                        instance.getId(),
                        "ENGINE",
                        decision.reason()
                );

                markedOverdue++;

            } catch (Exception ex) {
                skipped++;
                log.error(
                        "Failed to mark task overdue userId={} instanceId={}",
                        userId,
                        instance.getId(),
                        ex
                );
            }
        }

        return new OverdueSweepResult(
                userId,
                userToday,
                scanned,
                markedOverdue,
                skipped
        );
    }

    private TaskTemplate findTemplateOrNull(UUID templateId) {
        if (templateId == null) {
            return null;
        }

        return taskTemplateRepository.findById(templateId).orElse(null);
    }

    private LocalDate resolveUserToday(UUID userId) {
        return Instant.now()
                .atZone(userTimeService.getUserZoneId(userId))
                .toLocalDate();
    }

    private LocalDateTime resolveUserNow(UUID userId) {
        return Instant.now()
                .atZone(userTimeService.getUserZoneId(userId))
                .toLocalDateTime();
    }

    public record OverdueSweepResult(
            UUID userId,
            LocalDate date,
            int scanned,
            int markedOverdue,
            int skipped
    ) {
    }
}