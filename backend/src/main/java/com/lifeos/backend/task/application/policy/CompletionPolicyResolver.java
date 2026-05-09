package com.lifeos.backend.task.application.policy;

import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import org.springframework.stereotype.Component;

@Component
public class CompletionPolicyResolver {

    public CompletionDecision canComplete(TaskInstance instance) {
        if (instance == null) {
            return CompletionDecision.no("Task instance is required");
        }

        TaskInstanceStatus status = instance.getStatus();

        if (status == null) {
            return CompletionDecision.no("Task status is required");
        }

        if (!status.canComplete()) {
            return CompletionDecision.no("Task cannot be completed from status " + status);
        }

        return CompletionDecision.yes("Task can be completed");
    }

    public CompletionDecision canReopen(TaskInstance instance) {
        if (instance == null) {
            return CompletionDecision.no("Task instance is required");
        }

        TaskInstanceStatus status = instance.getStatus();

        if (status == null) {
            return CompletionDecision.no("Task status is required");
        }

        if (!status.canReopen()) {
            return CompletionDecision.no("Task cannot be reopened from status " + status);
        }

        return CompletionDecision.yes("Task can be reopened");
    }

    public CompletionDecision canClearDone(TaskInstance instance) {
        if (instance == null) {
            return CompletionDecision.no("Task instance is required");
        }

        if (instance.getStatus() != TaskInstanceStatus.COMPLETED) {
            return CompletionDecision.no("Only completed tasks can be cleared from Done");
        }

        if (instance.getDoneClearedAt() != null) {
            return CompletionDecision.no("Task is already cleared from Done");
        }

        return CompletionDecision.yes("Task can be cleared from Done");
    }

    public CompletionDecision canRestoreDone(TaskInstance instance) {
        if (instance == null) {
            return CompletionDecision.no("Task instance is required");
        }

        if (instance.getStatus() != TaskInstanceStatus.COMPLETED) {
            return CompletionDecision.no("Only completed tasks can be restored to Done");
        }

        if (instance.getDoneClearedAt() == null) {
            return CompletionDecision.no("Task is already visible in Done");
        }

        return CompletionDecision.yes("Task can be restored to Done");
    }

    public record CompletionDecision(
            boolean allowed,
            String reason
    ) {
        public static CompletionDecision yes(String reason) {
            return new CompletionDecision(true, reason);
        }

        public static CompletionDecision no(String reason) {
            return new CompletionDecision(false, reason);
        }
    }
}