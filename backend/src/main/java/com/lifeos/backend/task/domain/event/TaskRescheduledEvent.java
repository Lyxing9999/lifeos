package com.lifeos.backend.task.domain.event;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

public record TaskRescheduledEvent(
        UUID userId,
        UUID taskInstanceId,
        UUID taskTemplateId,

        String titleSnapshot,
        String categorySnapshot,
        String statusSnapshot,
        String prioritySnapshot,

        LocalDate fromScheduledDate,
        LocalDate toScheduledDate,

        LocalDateTime fromDueDateTime,
        LocalDateTime toDueDateTime,

        Instant rescheduledAt,
        String reason,
        String timezone
) {
}