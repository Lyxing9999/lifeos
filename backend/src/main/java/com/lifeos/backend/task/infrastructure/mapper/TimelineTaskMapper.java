package com.lifeos.backend.task.infrastructure.mapper;

import com.lifeos.backend.task.api.response.TimelineTaskResponse;
import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import org.springframework.stereotype.Component;

@Component
public class TimelineTaskMapper {

    public TimelineTaskResponse toResponse(TaskInstance instance) {
        if (instance == null) {
            return null;
        }

        return TimelineTaskResponse.builder()
                .id(instance.getId())
                .userId(instance.getUserId())
                .templateId(instance.getTemplateId())

                .title(instance.getTitleSnapshot())
                .status(instance.getStatus())
                .priority(instance.getPrioritySnapshot())
                .sourceType(instance.getSourceType())

                .occurrenceDate(instance.getOccurrenceDate())
                .scheduledDate(instance.getScheduledDate())
                .dueDateTime(instance.getDueDateTime())

                .startedAt(instance.getStartedAt())
                .completedAt(instance.getCompletedAt())
                .achievedDate(instance.getAchievedDate())

                .missedAt(instance.getMissedAt())
                .skippedAt(instance.getSkippedAt())
                .rolledOverAt(instance.getRolledOverAt())

                .linkedScheduleBlockId(instance.getLinkedScheduleBlockIdSnapshot())
                .rolledOverFromInstanceId(instance.getRolledOverFromInstanceId())
                .rolledOverToInstanceId(instance.getRolledOverToInstanceId())

                .timelineLane(resolveTimelineLane(instance))
                .build();
    }

    private String resolveTimelineLane(TaskInstance instance) {
        TaskInstanceStatus status = instance.getStatus();

        if (status == null) {
            return "UNKNOWN";
        }

        return switch (status) {
            case INBOX -> "INBOX";
            case SCHEDULED -> "SCHEDULED";
            case DUE_TODAY -> "DUE_TODAY";
            case IN_PROGRESS -> "IN_PROGRESS";
            case OVERDUE -> "OVERDUE";
            case COMPLETED -> "DONE";
            case ROLLED_OVER -> "ROLLED_OVER";
            case MISSED -> "MISSED";
            case SKIPPED -> "SKIPPED";
            case PAUSED -> "PAUSED";
            case ARCHIVED -> "ARCHIVED";
            case CANCELLED -> "CANCELLED";
        };
    }
}