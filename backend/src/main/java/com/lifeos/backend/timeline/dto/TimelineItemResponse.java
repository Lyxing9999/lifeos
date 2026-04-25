package com.lifeos.backend.timeline.dto;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Builder
public class TimelineItemResponse {
    private String itemType; // SCHEDULE, STAY, FINANCIAL
    private UUID itemId;
    private String title;
    private String subtitle;
    private LocalDateTime startDateTime;
    private LocalDateTime endDateTime;
    private String badge;
    private String status;
}