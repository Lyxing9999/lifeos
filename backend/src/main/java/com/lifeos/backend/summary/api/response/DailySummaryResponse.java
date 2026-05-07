package com.lifeos.backend.summary.api.response;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.util.UUID;

@Getter
@Builder
public class DailySummaryResponse {
    private UUID id;
    private UUID userId;
    private LocalDate summaryDate;
    private String summaryText;
    private String topPlaceName;
    private Long totalTasks;
    private Long completedTasks;
    private Long totalPlannedBlocks;
    private Long totalStaySessions;
    private String scoreExplanationText;
    private String optionalInsight;
}