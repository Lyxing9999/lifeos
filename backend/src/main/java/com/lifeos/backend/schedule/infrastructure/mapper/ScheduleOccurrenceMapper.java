package com.lifeos.backend.schedule.infrastructure.mapper;

import com.lifeos.backend.schedule.api.response.ScheduleOccurrenceResponse;
import com.lifeos.backend.schedule.domain.entity.ScheduleOccurrence;
import com.lifeos.backend.schedule.domain.enums.ScheduleOccurrenceStatus;
import org.springframework.stereotype.Component;

@Component
public class ScheduleOccurrenceMapper {

    public ScheduleOccurrenceResponse toResponse(ScheduleOccurrence occurrence) {
        if (occurrence == null) {
            return null;
        }

        return ScheduleOccurrenceResponse.builder()
                .id(occurrence.getId())
                .userId(occurrence.getUserId())
                .templateId(occurrence.getTemplateId())

                .title(occurrence.getTitleSnapshot())
                .type(occurrence.getTypeSnapshot())
                .description(occurrence.getDescriptionSnapshot())

                .occurrenceDate(occurrence.getOccurrenceDate())
                .scheduledDate(occurrence.getScheduledDate())

                .startDateTime(occurrence.getStartDateTime())
                .endDateTime(occurrence.getEndDateTime())

                .status(occurrence.getStatus())
                .previousStatus(occurrence.getPreviousStatus())
                .sourceType(occurrence.getSourceType())

                .linkedTaskInstanceId(occurrence.getLinkedTaskInstanceId())
                .linkedTaskTemplateId(occurrence.getLinkedTaskTemplateId())

                .rescheduledFromOccurrenceId(occurrence.getRescheduledFromOccurrenceId())
                .rescheduledToOccurrenceId(occurrence.getRescheduledToOccurrenceId())

                .activatedAt(occurrence.getActivatedAt())
                .expiredAt(occurrence.getExpiredAt())
                .cancelledAt(occurrence.getCancelledAt())
                .skippedAt(occurrence.getSkippedAt())
                .rescheduledAt(occurrence.getRescheduledAt())

                .createdAt(occurrence.getCreatedAt())
                .updatedAt(occurrence.getUpdatedAt())

                .open(occurrence.isOpen())
                .finalState(occurrence.isFinalState())
                .planned(occurrence.isPlanned())
                .active(occurrence.isActive())
                .expired(occurrence.isExpired())
                .cancelled(occurrence.isCancelled())
                .skipped(occurrence.isSkipped())
                .rescheduled(occurrence.isRescheduled())

                .timelineLane(resolveTimelineLane(occurrence))
                .build();
    }

    private String resolveTimelineLane(ScheduleOccurrence occurrence) {
        ScheduleOccurrenceStatus status = occurrence.getStatus();

        if (status == null) {
            return "UNKNOWN";
        }

        return switch (status) {
            case PLANNED -> "PLANNED";
            case ACTIVE -> "ACTIVE";
            case EXPIRED -> "EXPIRED";
            case CANCELLED -> "CANCELLED";
            case SKIPPED -> "SKIPPED";
            case RESCHEDULED -> "RESCHEDULED";
        };
    }
}