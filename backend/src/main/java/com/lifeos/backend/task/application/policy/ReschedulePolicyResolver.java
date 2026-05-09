package com.lifeos.backend.task.application.policy;

import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Component
public class ReschedulePolicyResolver {

    public RescheduleDecision canReschedule(
            TaskInstance instance,
            LocalDate targetScheduledDate,
            LocalDateTime targetDueDateTime
    ) {
        if (instance == null) {
            return RescheduleDecision.no("Task instance is required");
        }

        if (targetScheduledDate == null && targetDueDateTime == null) {
            return RescheduleDecision.no("targetScheduledDate or targetDueDateTime is required");
        }

        TaskInstanceStatus status = instance.getStatus();

        if (status == null) {
            return RescheduleDecision.no("Task status is required");
        }

        if (!status.canReschedule()) {
            return RescheduleDecision.no("Task cannot be rescheduled from status " + status);
        }

        LocalDate resolvedDate = resolveTargetDate(targetScheduledDate, targetDueDateTime);

        if (resolvedDate == null) {
            return RescheduleDecision.no("Could not resolve target scheduled date");
        }

        return RescheduleDecision.yes(
                resolvedDate,
                targetDueDateTime,
                "Task can be rescheduled"
        );
    }

    public RescheduleDecision canRescheduleFutureOccurrence(
            LocalDate occurrenceDate,
            LocalDate targetScheduledDate,
            LocalDateTime targetDueDateTime
    ) {
        if (occurrenceDate == null) {
            return RescheduleDecision.no("occurrenceDate is required");
        }

        if (targetScheduledDate == null && targetDueDateTime == null) {
            return RescheduleDecision.no("targetScheduledDate or targetDueDateTime is required");
        }

        LocalDate resolvedDate = resolveTargetDate(targetScheduledDate, targetDueDateTime);

        return RescheduleDecision.yes(
                resolvedDate,
                targetDueDateTime,
                "Future occurrence can be rescheduled"
        );
    }

    private LocalDate resolveTargetDate(
            LocalDate targetScheduledDate,
            LocalDateTime targetDueDateTime
    ) {
        if (targetScheduledDate != null) {
            return targetScheduledDate;
        }

        if (targetDueDateTime != null) {
            return targetDueDateTime.toLocalDate();
        }

        return null;
    }

    public record RescheduleDecision(
            boolean allowed,
            LocalDate targetScheduledDate,
            LocalDateTime targetDueDateTime,
            String reason
    ) {
        public static RescheduleDecision yes(
                LocalDate targetScheduledDate,
                LocalDateTime targetDueDateTime,
                String reason
        ) {
            return new RescheduleDecision(
                    true,
                    targetScheduledDate,
                    targetDueDateTime,
                    reason
            );
        }

        public static RescheduleDecision no(String reason) {
            return new RescheduleDecision(false, null, null, reason);
        }
    }
}