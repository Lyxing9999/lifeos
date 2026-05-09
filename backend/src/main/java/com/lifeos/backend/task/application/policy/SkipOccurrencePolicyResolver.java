package com.lifeos.backend.task.application.policy;

import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.entity.TaskTemplate;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

@Component
public class SkipOccurrencePolicyResolver {

    public SkipDecision canSkipExistingInstance(TaskInstance instance) {
        if (instance == null) {
            return SkipDecision.no("Task instance is required");
        }

        TaskInstanceStatus status = instance.getStatus();

        if (status == null) {
            return SkipDecision.no("Task status is required");
        }

        if (!status.canSkip()) {
            return SkipDecision.no("Task cannot be skipped from status " + status);
        }

        if (instance.getTemplateId() == null) {
            return SkipDecision.no("Only recurring/template-based task instances can be skipped as an occurrence");
        }

        if (instance.getOccurrenceDate() == null) {
            return SkipDecision.no("occurrenceDate is required to skip an occurrence");
        }

        return SkipDecision.yes(
                instance.getTemplateId(),
                instance.getOccurrenceDate(),
                true,
                "Existing occurrence can be skipped"
        );
    }

    public SkipDecision canSkipFutureOccurrence(
            TaskTemplate template,
            LocalDate occurrenceDate
    ) {
        if (template == null) {
            return SkipDecision.no("Task template is required");
        }

        if (!template.isRecurring()) {
            return SkipDecision.no("Only recurring templates can skip future occurrences");
        }

        if (occurrenceDate == null) {
            return SkipDecision.no("occurrenceDate is required");
        }

        return SkipDecision.yes(
                template.getId(),
                occurrenceDate,
                false,
                "Future occurrence can be skipped"
        );
    }

    public record SkipDecision(
            boolean allowed,
            java.util.UUID templateId,
            LocalDate occurrenceDate,
            boolean existingInstance,
            String reason
    ) {
        public static SkipDecision yes(
                java.util.UUID templateId,
                LocalDate occurrenceDate,
                boolean existingInstance,
                String reason
        ) {
            return new SkipDecision(
                    true,
                    templateId,
                    occurrenceDate,
                    existingInstance,
                    reason
            );
        }

        public static SkipDecision no(String reason) {
            return new SkipDecision(false, null, null, false, reason);
        }
    }
}