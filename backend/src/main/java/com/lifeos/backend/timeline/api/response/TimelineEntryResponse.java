package com.lifeos.backend.timeline.api.response;

import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Builder
public class TimelineEntryResponse {

    private UUID id;
    private UUID userId;

    private String entryType;
    private String sourceType;
    private String anchorType;

    private UUID sourceId;
    private UUID sourceTemplateId;
    private UUID sourceOccurrenceId;

    private Instant effectiveStartAt;
    private Instant effectiveEndAt;

    private LocalDateTime effectiveStartLocal;
    private LocalDateTime effectiveEndLocal;

    private String title;
    private String subtitle;
    private String category;
    private String status;
    private String badge;
    private String metadataJson;

    /**
     * Span clipping flags.
     *
     * Example:
     * Stay from 18:00 -> next day 08:00.
     *
     * On day 1:
     * clippedEnd = true
     *
     * On day 2:
     * clippedStart = true
     */
    private Boolean clippedStart;
    private Boolean clippedEnd;
    private Boolean startsBeforeDay;
    private Boolean endsAfterDay;
    private Boolean spansMultipleDays;

    private Long visibleDurationMinutes;
}