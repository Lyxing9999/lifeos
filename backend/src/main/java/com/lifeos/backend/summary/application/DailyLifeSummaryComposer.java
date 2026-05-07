package com.lifeos.backend.summary.application;

import org.springframework.stereotype.Component;

@Component
public class DailyLifeSummaryComposer {

    public String compose(
            String topPlaceName,
            long completedTasks,
            long totalTasks,
            long totalPlannedBlocks,
            long totalStaySessions,
            String financialSentence
    ) {
        StringBuilder sb = new StringBuilder();

        sb.append("Today you spent most of your detected time at ")
                .append(topPlaceName != null ? topPlaceName : "No dominant place")
                .append(", completed ")
                .append(completedTasks)
                .append(" of ")
                .append(totalTasks)
                .append(" tasks, and had ")
                .append(totalPlannedBlocks)
                .append(" planned schedule blocks.");

        if (totalStaySessions > 0) {
            sb.append(" You had ").append(totalStaySessions).append(" stay sessions detected.");
        } else {
            sb.append(" The day looked lightly structured with 0 stay sessions detected.");
        }

        if (financialSentence != null && !financialSentence.isBlank()) {
            sb.append(" ").append(financialSentence);
        }

        return sb.toString().trim();
    }
}