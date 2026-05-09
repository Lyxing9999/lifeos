package com.lifeos.backend.task.domain.statemachine.state;

import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.task.domain.enums.TaskTransitionType;
import com.lifeos.backend.task.domain.statemachine.TaskState;
import org.springframework.stereotype.Component;

@Component
public class MissedState implements TaskState {

    @Override
    public TaskInstanceStatus status() {
        return TaskInstanceStatus.MISSED;
    }

    @Override
    public boolean allows(TaskTransitionType transitionType) {
        return switch (transitionType) {
            case REOPEN,
                 ARCHIVE -> true;
            default -> false;
        };
    }
}