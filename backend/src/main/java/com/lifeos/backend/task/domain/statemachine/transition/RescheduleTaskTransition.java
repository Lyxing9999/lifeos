package com.lifeos.backend.task.domain.statemachine.transition;

import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.enums.MutationType;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.task.domain.enums.TaskTransitionType;
import com.lifeos.backend.task.domain.statemachine.TaskStateContext;
import com.lifeos.backend.task.domain.statemachine.TaskTransition;
import com.lifeos.backend.task.domain.statemachine.TaskTransitionCommand;
import com.lifeos.backend.task.domain.statemachine.TaskTransitionResult;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

@Component
public class RescheduleTaskTransition implements TaskTransition {

    @Override
    public boolean supports(TaskTransitionType transitionType) {
        return transitionType == TaskTransitionType.RESCHEDULE;
    }

    @Override
    public TaskTransitionResult apply(
            TaskInstance instance,
            TaskTransitionCommand command,
            TaskStateContext context
    ) {
        command.requireTargetScheduledDate();

        TaskInstanceStatus fromStatus = instance.getStatus();

        LocalDate fromScheduledDate = instance.getScheduledDate();
        var fromDueDateTime = instance.getDueDateTime();

        LocalDate targetScheduledDate = command.resolvedTargetScheduledDate();

        TaskInstanceStatus toStatus = resolveScheduledStatus(
                targetScheduledDate,
                context.userToday()
        );

        instance.setScheduledDate(targetScheduledDate);
        instance.setDueDateTime(command.targetDueDateTime());
        instance.setStatus(toStatus);

        return TaskTransitionResult.changedWithSchedule(
                instance.getUserId(),
                instance.getTemplateId(),
                instance.getId(),
                TaskTransitionType.RESCHEDULE,
                MutationType.INSTANCE_RESCHEDULED,
                fromStatus,
                toStatus,
                fromScheduledDate,
                targetScheduledDate,
                fromDueDateTime,
                command.targetDueDateTime(),
                command.safeActor(),
                command.safeReason(),
                command.metadataJson()
        );
    }

    private TaskInstanceStatus resolveScheduledStatus(
            LocalDate scheduledDate,
            LocalDate userToday
    ) {
        if (scheduledDate == null) {
            return TaskInstanceStatus.INBOX;
        }

        if (scheduledDate.isBefore(userToday)) {
            return TaskInstanceStatus.OVERDUE;
        }

        if (scheduledDate.equals(userToday)) {
            return TaskInstanceStatus.DUE_TODAY;
        }

        return TaskInstanceStatus.SCHEDULED;
    }
}