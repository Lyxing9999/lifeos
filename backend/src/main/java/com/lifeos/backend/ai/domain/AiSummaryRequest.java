package com.lifeos.backend.ai.domain;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AiSummaryRequest {
    private String date;
    private String timezone;
    private String topPlaceName;
    private Long topPlaceDurationMinutes;
    private Long totalTasks;
    private Long completedTasks;
    private Long totalPlannedBlocks;
    private Long totalStaySessions;
    private Integer completionScore;
    private Integer structureScore;
    private Integer overallScore;
}