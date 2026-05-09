package com.lifeos.backend.task.domain.statemachine.state;

import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.task.domain.enums.TaskTransitionType;
import com.lifeos.backend.task.domain.statemachine.TaskState;
import org.springframework.stereotype.Component;

@Component
public class CancelledState implements TaskState {

    @Override
    public TaskInstanceStatus status() {
        return TaskInstanceStatus.CANCELLED;
    }

    @Override
    public boolean allows(TaskTransitionType transitionType) {
        return false;
    }
}