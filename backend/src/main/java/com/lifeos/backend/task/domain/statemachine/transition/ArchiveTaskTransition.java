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
public class ArchiveTaskTransition implements TaskTransition {

    @Override
    public boolean supports(TaskTransitionType transitionType) {
        return transitionType == TaskTransitionType.ARCHIVE;
    }

    @Override
    public TaskTransitionResult apply(
            TaskInstance instance,
            TaskTransitionCommand command,
            TaskStateContext context
    ) {
        TaskInstanceStatus fromStatus = instance.getStatus();

        instance.rememberPreviousStatus();
        instance.setStatus(TaskInstanceStatus.ARCHIVED);
        instance.setArchivedAt(context.now());

        return TaskTransitionResult.changed(
                instance.getUserId(),
                instance.getTemplateId(),
                instance.getId(),
                TaskTransitionType.ARCHIVE,
                MutationType.INSTANCE_ARCHIVED,
                fromStatus,
                TaskInstanceStatus.ARCHIVED,
                command.safeActor(),
                command.safeReason()
        );
    }
}