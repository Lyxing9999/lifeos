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

@Component
public class RolloverTaskTransition implements TaskTransition {

    @Override
    public boolean supports(TaskTransitionType transitionType) {
        return transitionType == TaskTransitionType.ROLLOVER;
    }

    @Override
    public TaskTransitionResult apply(
            TaskInstance instance,
            TaskTransitionCommand command,
            TaskStateContext context
    ) {
        command.requireTargetScheduledDate();

        TaskInstanceStatus fromStatus = instance.getStatus();

        var fromScheduledDate = instance.getScheduledDate();
        var fromDueDateTime = instance.getDueDateTime();

        var targetScheduledDate = command.resolvedTargetScheduledDate();
        var targetDueDateTime = command.targetDueDateTime();

        /**
         * Important:
         * This transition marks the OLD instance as ROLLED_OVER.
         *
         * It does not create the new target instance.
         * Target creation belongs to TaskLifecycleOrchestrator / TaskRescheduleService
         * because that needs repository + factory.
         */
        instance.setStatus(TaskInstanceStatus.ROLLED_OVER);
        instance.setRolledOverAt(context.now());

        return TaskTransitionResult.changedWithSchedule(
                instance.getUserId(),
                instance.getTemplateId(),
                instance.getId(),
                TaskTransitionType.ROLLOVER,
                MutationType.INSTANCE_ROLLED_OVER,
                fromStatus,
                TaskInstanceStatus.ROLLED_OVER,
                fromScheduledDate,
                targetScheduledDate,
                fromDueDateTime,
                targetDueDateTime,
                command.safeActor(),
                command.safeReason(),
                command.metadataJson()
        );
    }
}