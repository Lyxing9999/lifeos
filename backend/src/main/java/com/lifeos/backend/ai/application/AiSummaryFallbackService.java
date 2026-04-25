package com.lifeos.backend.ai.application;

import com.lifeos.backend.ai.domain.AiSummaryRequest;
import com.lifeos.backend.ai.domain.AiSummaryResult;
import org.springframework.stereotype.Service;

@Service
public class AiSummaryFallbackService {

    public AiSummaryResult generate(AiSummaryRequest request) {
        String summary = String.format(
                "You spent most of your time at %s, completed %d of %d tasks, and had %d planned blocks with %d stay sessions.",
                request.getTopPlaceName(),
                request.getCompletedTasks(),
                request.getTotalTasks(),
                request.getTotalPlannedBlocks(),
                request.getTotalStaySessions()
        );

        String explanation = String.format(
                "Scores came from completion %d and structure %d, resulting in overall %d.",
                request.getCompletionScore(),
                request.getStructureScore(),
                request.getOverallScore()
        );

        String insight = String.format(
                "Your strongest place signal today was %s for %d minutes.",
                request.getTopPlaceName(),
                request.getTopPlaceDurationMinutes()
        );

        return AiSummaryResult.builder()
                .summaryText(summary)
                .scoreExplanation(explanation)
                .insight(insight)
                .fallbackUsed(true)
                .build();
    }
}