package com.lifeos.backend.task.domain.event;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public record TaskRolledOverEvent(
        UUID userId,

        UUID sourceTaskInstanceId,
        UUID targetTaskInstanceId,
        UUID taskTemplateId,

        String titleSnapshot,
        String categorySnapshot,
        String statusSnapshot,
        String prioritySnapshot,

        LocalDate fromScheduledDate,
        LocalDate toScheduledDate,

        Instant rolledOverAt,
        String reason,
        String timezone
) {
}