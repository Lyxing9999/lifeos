package com.lifeos.backend.task.infrastructure.mapper;

import com.lifeos.backend.task.api.response.TaskInstanceResponse;
import com.lifeos.backend.task.domain.entity.TaskInstance;
import org.springframework.stereotype.Component;

@Component
public class TaskInstanceMapper {

    public TaskInstanceResponse toResponse(TaskInstance instance) {
        if (instance == null) {
            return null;
        }

        return TaskInstanceResponse.builder()
                .id(instance.getId())
                .userId(instance.getUserId())
                .templateId(instance.getTemplateId())

                .title(instance.getTitleSnapshot())
                .description(instance.getDescriptionSnapshot())

                .status(instance.getStatus())
                .previousStatus(instance.getPreviousStatus())

                .priority(instance.getPrioritySnapshot())
                .category(instance.getCategorySnapshot())
                .sourceType(instance.getSourceType())

                .occurrenceDate(instance.getOccurrenceDate())
                .scheduledDate(instance.getScheduledDate())
                .dueDateTime(instance.getDueDateTime())

                .linkedScheduleBlockId(instance.getLinkedScheduleBlockIdSnapshot())

                .startedAt(instance.getStartedAt())
                .completedAt(instance.getCompletedAt())
                .achievedDate(instance.getAchievedDate())
                .doneClearedAt(instance.getDoneClearedAt())

                .missedAt(instance.getMissedAt())
                .skippedAt(instance.getSkippedAt())
                .rolledOverAt(instance.getRolledOverAt())

                .rolledOverFromInstanceId(instance.getRolledOverFromInstanceId())
                .rolledOverToInstanceId(instance.getRolledOverToInstanceId())

                .pausedAt(instance.getPausedAt())
                .archivedAt(instance.getArchivedAt())
                .cancelledAt(instance.getCancelledAt())

                .createdAt(instance.getCreatedAt())
                .updatedAt(instance.getUpdatedAt())

                .finalState(instance.isFinalState())
                .workable(instance.isWorkable())
                .completed(instance.isCompleted())
                .overdue(instance.isOverdue())
                .missed(instance.isMissed())
                .skipped(instance.isSkipped())
                .archived(instance.isArchived())
                .paused(instance.isPaused())
                .build();
    }
}