package com.lifeos.backend.task.application.policy;

import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.entity.TaskTemplate;
import com.lifeos.backend.task.domain.enums.MissedPolicy;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Component
public class MissedPolicyResolver {

    private static final int DEFAULT_GRACE_MINUTES = 30;

    public MissedDecision evaluate(
            TaskInstance instance,
            TaskTemplate template,
            LocalDate userToday,
            LocalDateTime userNow
    ) {
        return evaluate(instance, template, userToday, userNow, DEFAULT_GRACE_MINUTES);
    }

    public MissedDecision evaluate(
            TaskInstance instance,
            TaskTemplate template,
            LocalDate userToday,
            LocalDateTime userNow,
            int graceMinutes
    ) {
        if (instance == null) {
            return MissedDecision.no("Task instance is required");
        }

        if (!canMarkMissedFromStatus(instance.getStatus())) {
            return MissedDecision.no("Task cannot become MISSED from status " + instance.getStatus());
        }

        MissedPolicy policy = resolvePolicy(template);

        if (policy == MissedPolicy.NEVER_MISS) {
            return MissedDecision.no("Missed policy is NEVER_MISS");
        }

        boolean missed = switch (policy) {
            case NEVER_MISS -> false;

            case MISS_AFTER_DUE_TIME -> isAfterDueTime(instance, userNow);

            case MISS_AT_END_OF_DAY -> isAfterScheduledDate(instance, userToday);

            case MISS_AFTER_GRACE_PERIOD -> isAfterDueTimeWithGrace(
                    instance,
                    userNow,
                    graceMinutes
            );
        };

        if (!missed) {
            return MissedDecision.no("Task should not be marked MISSED yet");
        }

        return MissedDecision.yes(policy, "Task should become MISSED");
    }

    private MissedPolicy resolvePolicy(TaskTemplate template) {
        if (template == null || template.getMissedPolicy() == null) {
            return MissedPolicy.NEVER_MISS;
        }

        return template.getMissedPolicy();
    }

    private boolean canMarkMissedFromStatus(TaskInstanceStatus status) {
        return status == TaskInstanceStatus.DUE_TODAY
                || status == TaskInstanceStatus.IN_PROGRESS
                || status == TaskInstanceStatus.OVERDUE
                || status == TaskInstanceStatus.SCHEDULED;
    }

    private boolean isAfterDueTime(TaskInstance instance, LocalDateTime userNow) {
        if (instance.getDueDateTime() == null || userNow == null) {
            return false;
        }

        return instance.getDueDateTime().isBefore(userNow);
    }

    private boolean isAfterDueTimeWithGrace(
            TaskInstance instance,
            LocalDateTime userNow,
            int graceMinutes
    ) {
        if (instance.getDueDateTime() == null || userNow == null) {
            return false;
        }

        int safeGraceMinutes = Math.max(graceMinutes, 0);

        return instance.getDueDateTime()
                .plusMinutes(safeGraceMinutes)
                .isBefore(userNow);
    }

    private boolean isAfterScheduledDate(TaskInstance instance, LocalDate userToday) {
        if (userToday == null) {
            return false;
        }

        LocalDate scheduledDate = instance.getScheduledDate();

        if (scheduledDate == null && instance.getDueDateTime() != null) {
            scheduledDate = instance.getDueDateTime().toLocalDate();
        }

        return scheduledDate != null && scheduledDate.isBefore(userToday);
    }

    public record MissedDecision(
            boolean shouldMarkMissed,
            MissedPolicy policy,
            String reason
    ) {
        public static MissedDecision yes(MissedPolicy policy, String reason) {
            return new MissedDecision(true, policy, reason);
        }

        public static MissedDecision no(String reason) {
            return new MissedDecision(false, null, reason);
        }
    }
}