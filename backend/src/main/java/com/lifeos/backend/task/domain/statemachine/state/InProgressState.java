package com.lifeos.backend.task.domain.statemachine.state;

import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.task.domain.enums.TaskTransitionType;
import com.lifeos.backend.task.domain.statemachine.TaskState;
import org.springframework.stereotype.Component;

@Component
public class InProgressState implements TaskState {

    @Override
    public TaskInstanceStatus status() {
        return TaskInstanceStatus.IN_PROGRESS;
    }

    @Override
    public boolean allows(TaskTransitionType transitionType) {
        return switch (transitionType) {
            case COMPLETE,
                 ROLLOVER,
                 MARK_OVERDUE,
                 MARK_MISSED,
                 RESCHEDULE,
                 PAUSE,
                 ARCHIVE,
                 CANCEL -> true;
            default -> false;
        };
    }
}