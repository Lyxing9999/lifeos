package com.lifeos.backend.task.domain.statemachine.state;

import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.task.domain.enums.TaskTransitionType;
import com.lifeos.backend.task.domain.statemachine.TaskState;
import org.springframework.stereotype.Component;

@Component
public class PausedState implements TaskState {

    @Override
    public TaskInstanceStatus status() {
        return TaskInstanceStatus.PAUSED;
    }

    @Override
    public boolean allows(TaskTransitionType transitionType) {
        return switch (transitionType) {
            case RESUME,
                 ARCHIVE,
                 CANCEL -> true;
            default -> false;
        };
    }
}