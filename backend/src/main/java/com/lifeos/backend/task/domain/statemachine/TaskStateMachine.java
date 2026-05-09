package com.lifeos.backend.task.domain.statemachine;

import com.lifeos.backend.common.exception.DomainRuleException;
import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.task.domain.enums.TaskTransitionType;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * Central lifecycle gatekeeper.
 *
 * Responsibilities:
 * - verify current state exists
 * - verify transition is allowed from current state
 * - find matching transition handler
 * - apply mutation
 *
 * It does NOT:
 * - save repositories
 * - send notifications
 * - build Today screen
 * - build Timeline
 */
@Component
@RequiredArgsConstructor
public class TaskStateMachine {

    private final List<TaskState> states;
    private final List<TaskTransition> transitions;

    public TaskTransitionResult apply(
            TaskInstance instance,
            TaskTransitionCommand command,
            TaskStateContext context
    ) {
        validateInput(instance, command, context);

        TaskInstanceStatus currentStatus = instance.getStatus();
        TaskTransitionType transitionType = command.transitionType();

        TaskState currentState = findState(currentStatus);

        if (!currentState.allows(transitionType)) {
            throw new DomainRuleException(
                    "Transition not allowed: " + currentStatus + " -> " + transitionType
            );
        }

        TaskTransition transition = findTransition(transitionType);

        return transition.apply(instance, command, context);
    }

    private TaskState findState(TaskInstanceStatus status) {
        return states.stream()
                .filter(state -> state.status() == status)
                .findFirst()
                .orElseThrow(() -> new DomainRuleException("Unknown task state: " + status));
    }

    private TaskTransition findTransition(TaskTransitionType transitionType) {
        return transitions.stream()
                .filter(transition -> transition.supports(transitionType))
                .findFirst()
                .orElseThrow(() -> new DomainRuleException(
                        "Transition handler not found: " + transitionType
                ));
    }

    private void validateInput(
            TaskInstance instance,
            TaskTransitionCommand command,
            TaskStateContext context
    ) {
        if (instance == null) {
            throw new IllegalArgumentException("TaskInstance is required");
        }

        if (instance.getStatus() == null) {
            throw new DomainRuleException("TaskInstance status is required");
        }

        if (command == null) {
            throw new IllegalArgumentException("TaskTransitionCommand is required");
        }

        command.requireTransitionType();

        if (context == null) {
            throw new IllegalArgumentException("TaskStateContext is required");
        }

        if (command.userId() != null && !command.userId().equals(instance.getUserId())) {
            throw new DomainRuleException("Task instance does not belong to user");
        }
    }
}