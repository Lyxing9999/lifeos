package com.lifeos.backend.task.domain.statemachine;

import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.enums.TaskTransitionType;

/**
 * Applies actual state mutation for one transition type.
 */
public interface TaskTransition {

    boolean supports(TaskTransitionType transitionType);

    TaskTransitionResult apply(
            TaskInstance instance,
            TaskTransitionCommand command,
            TaskStateContext context
    );
}