package com.lifeos.backend.task.application.policy;

import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.entity.TaskTemplate;
import com.lifeos.backend.task.domain.enums.RolloverPolicy;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Component
@RequiredArgsConstructor
public class RolloverPolicyResolver {

    private final RecurrencePolicyResolver recurrencePolicyResolver;

    public RolloverDecision evaluate(
            TaskInstance instance,
            TaskTemplate template,
            LocalDate userToday
    ) {
        if (instance == null) {
            return RolloverDecision.no("Task instance is required");
        }

        if (userToday == null) {
            return RolloverDecision.no("userToday is required");
        }

        if (!canRolloverFromStatus(instance.getStatus())) {
            return RolloverDecision.no("Task cannot rollover from status " + instance.getStatus());
        }

        RolloverPolicy policy = resolvePolicy(template);

        if (!policy.allowsRollover()) {
            return RolloverDecision.no("Rollover policy does not allow rollover: " + policy);
        }

        LocalDate targetDate = switch (policy) {
            case DO_NOT_ROLLOVER, KEEP_OVERDUE -> null;
            case ROLLOVER_TO_NEXT_DAY -> userToday.plusDays(1);
            case ROLLOVER_TO_NEXT_AVAILABLE_DAY -> resolveNextAvailableDate(template, userToday);
        };

        if (targetDate == null) {
            return RolloverDecision.no("Could not resolve rollover target date");
        }

        LocalDateTime targetDueDateTime = null;

        if (instance.getDueDateTime() != null) {
            targetDueDateTime = targetDate.atTime(instance.getDueDateTime().toLocalTime());
        } else if (template != null && template.getDefaultDueTime() != null) {
            targetDueDateTime = targetDate.atTime(template.getDefaultDueTime());
        }

        return RolloverDecision.yes(
                policy,
                targetDate,
                targetDueDateTime,
                "Task should rollover to " + targetDate
        );
    }

    private RolloverPolicy resolvePolicy(TaskTemplate template) {
        if (template == null || template.getRolloverPolicy() == null) {
            return RolloverPolicy.KEEP_OVERDUE;
        }

        return template.getRolloverPolicy();
    }

    private boolean canRolloverFromStatus(TaskInstanceStatus status) {
        return status == TaskInstanceStatus.DUE_TODAY
                || status == TaskInstanceStatus.IN_PROGRESS
                || status == TaskInstanceStatus.OVERDUE;
    }

    private LocalDate resolveNextAvailableDate(TaskTemplate template, LocalDate userToday) {
        if (template == null || !template.isRecurring()) {
            return userToday.plusDays(1);
        }

        LocalDate next = recurrencePolicyResolver.nextOccurrenceAfter(template, userToday);

        return next == null ? userToday.plusDays(1) : next;
    }

    public record RolloverDecision(
            boolean shouldRollover,
            RolloverPolicy policy,
            LocalDate targetScheduledDate,
            LocalDateTime targetDueDateTime,
            String reason
    ) {
        public static RolloverDecision yes(
                RolloverPolicy policy,
                LocalDate targetScheduledDate,
                LocalDateTime targetDueDateTime,
                String reason
        ) {
            return new RolloverDecision(
                    true,
                    policy,
                    targetScheduledDate,
                    targetDueDateTime,
                    reason
            );
        }

        public static RolloverDecision no(String reason) {
            return new RolloverDecision(false, null, null, null, reason);
        }
    }
}