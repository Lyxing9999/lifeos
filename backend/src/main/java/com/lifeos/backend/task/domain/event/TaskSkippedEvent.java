package com.lifeos.backend.task.domain.event;

import java.time.Instant;
import java.util.UUID;

public record TaskSkippedEvent(
        UUID userId,
        UUID taskInstanceId,
        UUID taskTemplateId,

        String titleSnapshot,
        String categorySnapshot,
        String statusSnapshot,
        String prioritySnapshot,

        Instant skippedAt,
        String reason,
        String timezone
) {
}