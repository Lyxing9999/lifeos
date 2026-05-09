package com.lifeos.backend.task.domain.service;

import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.entity.TaskTemplate;
import com.lifeos.backend.task.domain.enums.OverduePolicy;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Component
public class OverdueEvaluationService {

    private static final int DEFAULT_GRACE_MINUTES = 30;

    public DueEvaluation evaluate(
            TaskInstance instance,
            TaskTemplate template,
            LocalDate userToday,
            LocalDateTime userNow
    ) {
        return evaluate(
                instance,
                template,
                userToday,
                userNow,
                DEFAULT_GRACE_MINUTES
        );
    }

    public DueEvaluation evaluate(
            TaskInstance instance,
            TaskTemplate template,
            LocalDate userToday,
            LocalDateTime userNow,
            int graceMinutes
    ) {
        if (instance == null) {
            return DueEvaluation.invalid("TaskInstance is required");
        }

        if (instance.getStatus() == null) {
            return DueEvaluation.invalid("TaskInstance status is required");
        }

        if (!isOpenStatus(instance.getStatus())) {
            return DueEvaluation.notDue("Task is not open for due evaluation");
        }

        LocalDate scheduledDate = effectiveScheduledDate(instance);

        if (scheduledDate == null) {
            return DueEvaluation.inbox("Task has no scheduled date");
        }

        if (userToday == null) {
            return DueEvaluation.invalid("userToday is required");
        }

        if (scheduledDate.isAfter(userToday)) {
            return DueEvaluation.future("Task is scheduled in the future");
        }

        if (scheduledDate.equals(userToday)) {
            if (isPastDueTime(instance, userNow, template, graceMinutes)) {
                return DueEvaluation.overdue("Task due time has passed");
            }

            return DueEvaluation.dueToday("Task is due today");
        }

        if (shouldBecomeOverdue(instance, template, userToday, userNow, graceMinutes)) {
            return DueEvaluation.overdue("Task scheduled date has passed");
        }

        return DueEvaluation.notDue("Task should not become overdue");
    }

    public boolean shouldBecomeOverdue(
            TaskInstance instance,
            TaskTemplate template,
            LocalDate userToday,
            LocalDateTime userNow
    ) {
        return shouldBecomeOverdue(
                instance,
                template,
                userToday,
                userNow,
                DEFAULT_GRACE_MINUTES
        );
    }

    public boolean shouldBecomeOverdue(
            TaskInstance instance,
            TaskTemplate template,
            LocalDate userToday,
            LocalDateTime userNow,
            int graceMinutes
    ) {
        if (instance == null || userToday == null) {
            return false;
        }

        if (!isOpenStatus(instance.getStatus())) {
            return false;
        }

        OverduePolicy policy = resolvePolicy(template);

        if (policy == OverduePolicy.NEVER_OVERDUE) {
            return false;
        }

        return switch (policy) {
            case NEVER_OVERDUE -> false;
            case OVERDUE_AFTER_DATE -> isAfterScheduledDate(instance, userToday);
            case OVERDUE_AFTER_TIME -> isAfterDueTime(instance, userNow);
            case OVERDUE_AT_END_OF_DAY -> isAfterScheduledDate(instance, userToday);
            case OVERDUE_AFTER_GRACE_PERIOD -> isAfterDueTimeWithGrace(instance, userNow, graceMinutes);
        };
    }

    private OverduePolicy resolvePolicy(TaskTemplate template) {
        if (template == null || template.getOverduePolicy() == null) {
            return OverduePolicy.OVERDUE_AT_END_OF_DAY;
        }

        return template.getOverduePolicy();
    }

    private boolean isOpenStatus(TaskInstanceStatus status) {
        return status == TaskInstanceStatus.INBOX
                || status == TaskInstanceStatus.SCHEDULED
                || status == TaskInstanceStatus.DUE_TODAY
                || status == TaskInstanceStatus.IN_PROGRESS
                || status == TaskInstanceStatus.OVERDUE;
    }

    private LocalDate effectiveScheduledDate(TaskInstance instance) {
        if (instance.getScheduledDate() != null) {
            return instance.getScheduledDate();
        }

        if (instance.getDueDateTime() != null) {
            return instance.getDueDateTime().toLocalDate();
        }

        return null;
    }

    private boolean isAfterScheduledDate(
            TaskInstance instance,
            LocalDate userToday
    ) {
        LocalDate scheduledDate = effectiveScheduledDate(instance);
        return scheduledDate != null && scheduledDate.isBefore(userToday);
    }

    private boolean isAfterDueTime(
            TaskInstance instance,
            LocalDateTime userNow
    ) {
        return instance.getDueDateTime() != null
                && userNow != null
                && instance.getDueDateTime().isBefore(userNow);
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

    private boolean isPastDueTime(
            TaskInstance instance,
            LocalDateTime userNow,
            TaskTemplate template,
            int graceMinutes
    ) {
        OverduePolicy policy = resolvePolicy(template);

        if (policy == OverduePolicy.OVERDUE_AFTER_TIME) {
            return isAfterDueTime(instance, userNow);
        }

        if (policy == OverduePolicy.OVERDUE_AFTER_GRACE_PERIOD) {
            return isAfterDueTimeWithGrace(instance, userNow, graceMinutes);
        }

        return false;
    }

    public record DueEvaluation(
            DuePosition position,
            boolean shouldMarkOverdue,
            String reason
    ) {
        public static DueEvaluation invalid(String reason) {
            return new DueEvaluation(DuePosition.INVALID, false, reason);
        }

        public static DueEvaluation inbox(String reason) {
            return new DueEvaluation(DuePosition.INBOX, false, reason);
        }

        public static DueEvaluation future(String reason) {
            return new DueEvaluation(DuePosition.FUTURE, false, reason);
        }

        public static DueEvaluation dueToday(String reason) {
            return new DueEvaluation(DuePosition.DUE_TODAY, false, reason);
        }

        public static DueEvaluation overdue(String reason) {
            return new DueEvaluation(DuePosition.OVERDUE, true, reason);
        }

        public static DueEvaluation notDue(String reason) {
            return new DueEvaluation(DuePosition.NOT_DUE, false, reason);
        }
    }

    public enum DuePosition {
        INVALID,
        INBOX,
        FUTURE,
        DUE_TODAY,
        OVERDUE,
        NOT_DUE
    }
}