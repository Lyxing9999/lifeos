package com.lifeos.backend.task.infrastructure.mapper;

import com.lifeos.backend.task.api.response.TaskTemplateResponse;
import com.lifeos.backend.task.domain.entity.TaskTemplate;
import org.springframework.stereotype.Component;

@Component
public class TaskTemplateMapper {

    public TaskTemplateResponse toResponse(TaskTemplate template) {
        if (template == null) {
            return null;
        }

        return TaskTemplateResponse.builder()
                .id(template.getId())
                .userId(template.getUserId())
                .title(template.getTitle())
                .description(template.getDescription())
                .status(template.getStatus())
                .priority(template.getPriority())
                .category(template.getCategory())

                .recurrenceType(template.getRecurrenceType())
                .recurrenceStartDate(template.getRecurrenceStartDate())
                .recurrenceEndDate(template.getRecurrenceEndDate())
                .recurrenceDaysOfWeek(template.getRecurrenceDaysOfWeek())

                .defaultDueTime(template.getDefaultDueTime())
                .defaultDurationMinutes(template.getDefaultDurationMinutes())
                .linkedScheduleBlockId(template.getLinkedScheduleBlockId())

                .overduePolicy(template.getOverduePolicy())
                .rolloverPolicy(template.getRolloverPolicy())
                .missedPolicy(template.getMissedPolicy())

                .archived(template.getArchived())
                .archivedAt(template.getArchivedAt())
                .paused(template.getPaused())
                .pausedAt(template.getPausedAt())

                .createdAt(template.getCreatedAt())
                .updatedAt(template.getUpdatedAt())

                .recurring(template.isRecurring())
                .activeTemplate(template.isActiveTemplate())
                .build();
    }
}