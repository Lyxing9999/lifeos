package com.lifeos.backend.score.application;

import org.springframework.stereotype.Component;

@Component
public class DailyScoreExplanationComposer {

    public String compose(
            long completedTasks,
            int totalTasks,
            int totalPlannedBlocks,
            int totalStaySessions,
            int completionScore,
            int structureScore,
            int overallScore
    ) {
        String completionPart = buildCompletionPart(completedTasks, totalTasks, completionScore);
        String structurePart = buildStructurePart(totalPlannedBlocks, totalStaySessions, structureScore);
        String overallPart = buildOverallPart(overallScore);

        return completionPart + " " + structurePart + " " + overallPart;
    }

    private String buildCompletionPart(long completedTasks, int totalTasks, int completionScore) {
        if (totalTasks <= 0) {
            return "Completion score was 0 because there were no relevant tasks for the day.";
        }

        return "Completion score was " + completionScore
                + " based on " + completedTasks
                + " of " + totalTasks
                + " relevant tasks completed.";
    }

    private String buildStructurePart(int totalPlannedBlocks, int totalStaySessions, int structureScore) {
        if (totalPlannedBlocks <= 0 && totalStaySessions <= 0) {
            return "Structure score was 0 because there were no schedule blocks or stay sessions detected.";
        }

        return "Structure score was " + structureScore
                + " based on " + totalPlannedBlocks
                + " schedule blocks and "
                + totalStaySessions
                + " stay sessions.";
    }

    private String buildOverallPart(int overallScore) {
        return "Overall score was " + overallScore + ".";
    }
}