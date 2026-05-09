package com.lifeos.backend.schedule.infrastructure.mapper;

import com.lifeos.backend.schedule.api.response.ScheduleExceptionResponse;
import com.lifeos.backend.schedule.domain.entity.ScheduleException;
import org.springframework.stereotype.Component;

@Component
public class ScheduleExceptionMapper {

    public ScheduleExceptionResponse toResponse(ScheduleException exception) {
        if (exception == null) {
            return null;
        }

        return ScheduleExceptionResponse.builder()
                .id(exception.getId())
                .userId(exception.getUserId())
                .templateId(exception.getTemplateId())

                .occurrenceDate(exception.getOccurrenceDate())
                .type(exception.getType())

                .scheduleOccurrenceId(exception.getScheduleOccurrenceId())

                .rescheduledDate(exception.getRescheduledDate())
                .rescheduledStartDateTime(exception.getRescheduledStartDateTime())
                .rescheduledEndDateTime(exception.getRescheduledEndDateTime())

                .reason(exception.getReason())
                .appliedAt(exception.getAppliedAt())

                .createdAt(exception.getCreatedAt())
                .updatedAt(exception.getUpdatedAt())

                .skipped(exception.isSkipped())
                .rescheduled(exception.isRescheduled())
                .cancelled(exception.isCancelled())
                .preventsOriginalSpawn(exception.preventsOriginalSpawn())
                .build();
    }
}