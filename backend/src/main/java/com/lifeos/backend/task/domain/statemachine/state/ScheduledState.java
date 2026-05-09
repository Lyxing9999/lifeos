package com.lifeos.backend.task.domain.statemachine.state;

import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.task.domain.enums.TaskTransitionType;
import com.lifeos.backend.task.domain.statemachine.TaskState;
import org.springframework.stereotype.Component;

@Component
public class ScheduledState implements TaskState {

    @Override
    public TaskInstanceStatus status() {
        return TaskInstanceStatus.SCHEDULED;
    }

    @Override
    public boolean allows(TaskTransitionType transitionType) {
        return switch (transitionType) {
            case START,
                 COMPLETE,
                 MARK_OVERDUE,
                 MARK_MISSED,
                 RESCHEDULE,
                 SKIP_OCCURRENCE,
                 PAUSE,
                 ARCHIVE,
                 CANCEL -> true;
            default -> false;
        };
    }
}