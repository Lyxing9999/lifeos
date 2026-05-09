package com.lifeos.backend.task.infrastructure.mapper;

import com.lifeos.backend.task.api.response.TaskLifecycleResultResponse;
import com.lifeos.backend.task.application.command.TaskLifecycleOrchestrator.TaskLifecycleResult;
import com.lifeos.backend.task.domain.statemachine.TaskTransitionResult;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class TaskLifecycleResultMapper {

    private final TaskInstanceMapper taskInstanceMapper;

    public TaskLifecycleResultResponse toResponse(TaskLifecycleResult result) {
        if (result == null) {
            return null;
        }

        return TaskLifecycleResultResponse.builder()
                .instance(taskInstanceMapper.toResponse(result.instance()))
                .createdTargetInstance(taskInstanceMapper.toResponse(result.createdTargetInstance()))
                .transition(toTransitionResponse(result.transitionResult()))
                .messages(result.messages())
                .build();
    }

    private TaskLifecycleResultResponse.TransitionResponse toTransitionResponse(
            TaskTransitionResult result
    ) {
        if (result == null) {
            return null;
        }

        return TaskLifecycleResultResponse.TransitionResponse.builder()
                .transitionType(result.transitionType())
                .mutationType(result.mutationType())
                .fromStatus(result.fromStatus())
                .toStatus(result.toStatus())
                .changed(result.changed())
                .actor(result.actor())
                .reason(result.reason())
                .build();
    }
}