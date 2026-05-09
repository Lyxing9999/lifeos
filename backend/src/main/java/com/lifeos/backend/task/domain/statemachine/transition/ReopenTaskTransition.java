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
public class ReopenTaskTransition implements TaskTransition {

    @Override
    public boolean supports(TaskTransitionType transitionType) {
        return transitionType == TaskTransitionType.REOPEN;
    }

    @Override
    public TaskTransitionResult apply(
            TaskInstance instance,
            TaskTransitionCommand command,
            TaskStateContext context
    ) {
        TaskInstanceStatus fromStatus = instance.getStatus();
        TaskInstanceStatus toStatus = resolveOpenStatus(instance, context.userToday());

        instance.setStatus(toStatus);
        instance.setPreviousStatus(null);

        instance.setCompletedAt(null);
        instance.setAchievedDate(null);
        instance.setDoneClearedAt(null);

        instance.setMissedAt(null);
        instance.setSkippedAt(null);
        instance.setRolledOverAt(null);
        instance.setCancelledAt(null);

        return TaskTransitionResult.changed(
                instance.getUserId(),
                instance.getTemplateId(),
                instance.getId(),
                TaskTransitionType.REOPEN,
                MutationType.INSTANCE_REOPENED,
                fromStatus,
                toStatus,
                command.safeActor(),
                command.safeReason()
        );
    }

    private TaskInstanceStatus resolveOpenStatus(TaskInstance instance, LocalDate userToday) {
        if (instance.getScheduledDate() == null) {
            return TaskInstanceStatus.INBOX;
        }

        if (instance.getScheduledDate().isBefore(userToday)) {
            return TaskInstanceStatus.OVERDUE;
        }

        if (instance.getScheduledDate().equals(userToday)) {
            return TaskInstanceStatus.DUE_TODAY;
        }

        return TaskInstanceStatus.SCHEDULED;
    }
}