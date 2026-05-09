package com.lifeos.backend.task.application.policy;

import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.entity.TaskTemplate;
import com.lifeos.backend.task.domain.enums.OverduePolicy;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Component
public class OverduePolicyResolver {

    private static final int DEFAULT_GRACE_MINUTES = 30;

    public OverdueDecision evaluate(
            TaskInstance instance,
            TaskTemplate template,
            LocalDate userToday,
            LocalDateTime userNow
    ) {
        return evaluate(instance, template, userToday, userNow, DEFAULT_GRACE_MINUTES);
    }

    public OverdueDecision evaluate(
            TaskInstance instance,
            TaskTemplate template,
            LocalDate userToday,
            LocalDateTime userNow,
            int graceMinutes
    ) {
        if (instance == null) {
            return OverdueDecision.no("Task instance is required");
        }

        if (!isOpenForOverdue(instance)) {
            return OverdueDecision.no("Task is not open for overdue evaluation");
        }

        OverduePolicy policy = resolvePolicy(template);

        if (policy == OverduePolicy.NEVER_OVERDUE) {
            return OverdueDecision.no("Overdue policy is NEVER_OVERDUE");
        }

        if (userToday == null) {
            return OverdueDecision.no("userToday is required");
        }

        if (policy.requiresExactDueTime() && instance.getDueDateTime() == null) {
            return OverdueDecision.no("Exact dueDateTime is required for this overdue policy");
        }

        boolean overdue = switch (policy) {
            case NEVER_OVERDUE -> false;

            case OVERDUE_AFTER_DATE -> isAfterScheduledDate(instance, userToday);

            case OVERDUE_AFTER_TIME -> isAfterDueTime(instance, userNow);

            case OVERDUE_AT_END_OF_DAY -> isAfterScheduledDate(instance, userToday);

            case OVERDUE_AFTER_GRACE_PERIOD -> isAfterDueTimeWithGrace(
                    instance,
                    userNow,
                    graceMinutes
            );
        };

        if (!overdue) {
            return OverdueDecision.no("Task is not overdue yet");
        }

        return OverdueDecision.yes(policy, "Task should become OVERDUE");
    }

    private OverduePolicy resolvePolicy(TaskTemplate template) {
        if (template == null || template.getOverduePolicy() == null) {
            return OverduePolicy.OVERDUE_AT_END_OF_DAY;
        }

        return template.getOverduePolicy();
    }

    private boolean isOpenForOverdue(TaskInstance instance) {
        TaskInstanceStatus status = instance.getStatus();

        return status == TaskInstanceStatus.SCHEDULED
                || status == TaskInstanceStatus.DUE_TODAY
                || status == TaskInstanceStatus.IN_PROGRESS;
    }

    private boolean isAfterScheduledDate(TaskInstance instance, LocalDate userToday) {
        LocalDate scheduledDate = instance.getScheduledDate();

        if (scheduledDate == null && instance.getDueDateTime() != null) {
            scheduledDate = instance.getDueDateTime().toLocalDate();
        }

        return scheduledDate != null && scheduledDate.isBefore(userToday);
    }

    private boolean isAfterDueTime(TaskInstance instance, LocalDateTime userNow) {
        if (userNow == null || instance.getDueDateTime() == null) {
            return false;
        }

        return instance.getDueDateTime().isBefore(userNow);
    }

    private boolean isAfterDueTimeWithGrace(
            TaskInstance instance,
            LocalDateTime userNow,
            int graceMinutes
    ) {
        if (userNow == null || instance.getDueDateTime() == null) {
            return false;
        }

        int safeGraceMinutes = Math.max(graceMinutes, 0);

        return instance.getDueDateTime()
                .plusMinutes(safeGraceMinutes)
                .isBefore(userNow);
    }

    public record OverdueDecision(
            boolean shouldMarkOverdue,
            OverduePolicy policy,
            String reason
    ) {
        public static OverdueDecision yes(OverduePolicy policy, String reason) {
            return new OverdueDecision(true, policy, reason);
        }

        public static OverdueDecision no(String reason) {
            return new OverdueDecision(false, null, reason);
        }
    }
}