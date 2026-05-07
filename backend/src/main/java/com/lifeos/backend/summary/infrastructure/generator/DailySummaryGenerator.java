package com.lifeos.backend.summary.infrastructure.generator;

import com.lifeos.backend.schedule.api.response.ScheduleOccurrenceResponse;
import com.lifeos.backend.staysession.api.response.StaySessionResponse;
import com.lifeos.backend.task.api.response.TaskResponse;
import com.lifeos.backend.task.domain.enums.TaskStatus;
import org.springframework.stereotype.Component;

import java.util.Comparator;
import java.util.List;

@Component
public class DailySummaryGenerator {

    public String generate(
            List<TaskResponse> tasks,
            List<ScheduleOccurrenceResponse> schedules,
            List<StaySessionResponse> staySessions
    ) {
        long totalTasks = tasks.size();
        long completedTasks = tasks.stream().filter(t -> t.getStatus() == TaskStatus.COMPLETED).count();
        long plannedBlocks = schedules.size();
        long stayCount = staySessions.size();

        String topPlace = staySessions.stream()
                .filter(s -> s.getPlaceName() != null)
                .max(Comparator.comparingLong(StaySessionResponse::getDurationMinutes))
                .map(StaySessionResponse::getPlaceName)
                .orElse("No dominant place");

        String structureLabel;
        if (plannedBlocks >= 3 && stayCount >= 2) {
            structureLabel = "well structured";
        } else if (plannedBlocks >= 1 || stayCount >= 1) {
            structureLabel = "moderately structured";
        } else {
            structureLabel = "lightly structured";
        }

        return String.format(
                "You spent most of your detected time at %s, completed %d of %d tasks, and had %d planned blocks. The day looked %s with %d stay sessions.",
                topPlace,
                completedTasks,
                totalTasks,
                plannedBlocks,
                structureLabel,
                stayCount
        );
    }

    public String buildScoreExplanation(long completedTasks, long totalTasks, long plannedBlocks, long staySessions) {
        return String.format(
                "You completed %d of %d tasks with %d planned blocks and %d stay sessions contributing to today’s score.",
                completedTasks,
                totalTasks,
                plannedBlocks,
                staySessions
        );
    }

    public String buildOptionalInsight(List<StaySessionResponse> staySessions) {
        StaySessionResponse top = staySessions.stream()
                .max(Comparator.comparingLong(StaySessionResponse::getDurationMinutes))
                .orElse(null);

        if (top == null) {
            return "No strong place pattern was detected today.";
        }

        return String.format(
                "Your longest detected stay was at %s for %d minutes.",
                top.getPlaceName(),
                top.getDurationMinutes()
        );
    }
}