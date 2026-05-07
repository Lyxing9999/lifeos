package com.lifeos.backend.score.api.response;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.util.UUID;

@Getter
@Builder
public class DailyScoreResponse {
    private UUID id;
    private UUID userId;
    private LocalDate scoreDate;
    private Integer completionScore;
    private Integer structureScore;
    private Integer overallScore;
    private Integer completedTasks;
    private Integer totalTasks;
    private Integer totalPlannedBlocks;
    private Integer totalStaySessions;
    private String scoreExplanation;
}