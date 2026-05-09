package com.lifeos.backend.task.domain.statemachine;

import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.task.domain.enums.TaskTransitionType;

/**
 * Represents allowed transitions from a current status.
 */
public interface TaskState {

    TaskInstanceStatus status();

    boolean allows(TaskTransitionType transitionType);
}