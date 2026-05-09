package com.lifeos.backend.schedule.infrastructure.mapper;

import com.lifeos.backend.schedule.api.response.ScheduleTemplateResponse;
import com.lifeos.backend.schedule.domain.entity.ScheduleTemplate;
import org.springframework.stereotype.Component;

@Component
public class ScheduleTemplateMapper {

    public ScheduleTemplateResponse toResponse(ScheduleTemplate template) {
        if (template == null) {
            return null;
        }

        return ScheduleTemplateResponse.builder()
                .id(template.getId())
                .userId(template.getUserId())

                .title(template.getTitle())
                .description(template.getDescription())
                .type(template.getType())

                .startTime(template.getStartTime())
                .endTime(template.getEndTime())

                .status(template.getStatus())

                .recurrenceType(template.getRecurrenceType())
                .recurrenceDaysOfWeek(template.getRecurrenceDaysOfWeek())
                .recurrenceStartDate(template.getRecurrenceStartDate())
                .recurrenceEndDate(template.getRecurrenceEndDate())

                .colorKey(template.getColorKey())
                .externalCalendarId(template.getExternalCalendarId())

                .archivedAt(template.getArchivedAt())
                .pausedAt(template.getPausedAt())

                .createdAt(template.getCreatedAt())
                .updatedAt(template.getUpdatedAt())

                .activeTemplate(template.isActiveTemplate())
                .paused(template.isPaused())
                .archived(template.isArchived())
                .recurring(template.isRecurring())
                .oneTime(template.isOneTime())
                .canSpawnOccurrences(template.canSpawnOccurrences())
                .build();
    }
}