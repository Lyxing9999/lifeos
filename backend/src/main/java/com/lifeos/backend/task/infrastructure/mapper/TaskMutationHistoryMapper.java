package com.lifeos.backend.task.infrastructure.mapper;

import com.lifeos.backend.task.api.response.TaskMutationHistoryResponse;
import com.lifeos.backend.task.domain.entity.MutationHistory;
import org.springframework.stereotype.Component;

@Component
public class TaskMutationHistoryMapper {

    public TaskMutationHistoryResponse toResponse(MutationHistory history) {
        if (history == null) {
            return null;
        }

        return TaskMutationHistoryResponse.builder()
                .id(history.getId())
                .userId(history.getUserId())
                .templateId(history.getTemplateId())
                .taskInstanceId(history.getTaskInstanceId())

                .mutationType(history.getMutationType())
                .transitionType(history.getTransitionType())

                .fromStatus(history.getFromStatus())
                .toStatus(history.getToStatus())

                .fromScheduledDate(history.getFromScheduledDate())
                .toScheduledDate(history.getToScheduledDate())

                .fromDueDateTime(history.getFromDueDateTime())
                .toDueDateTime(history.getToDueDateTime())

                .reason(history.getReason())
                .actor(history.getActor())
                .occurredAt(history.getOccurredAt())
                .metadataJson(history.getMetadataJson())

                .createdAt(history.getCreatedAt())
                .updatedAt(history.getUpdatedAt())
                .build();
    }
}