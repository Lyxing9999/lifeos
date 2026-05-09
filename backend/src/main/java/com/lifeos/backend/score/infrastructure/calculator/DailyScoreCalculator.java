//package com.lifeos.backend.score.infrastructure.calculator;
//
//import com.lifeos.backend.score.application.DailyScoreExplanationComposer;
//import com.lifeos.backend.score.domain.DailyScore;
//import com.lifeos.backend.schedule.api.response.ScheduleOccurrenceResponse;
//import com.lifeos.backend.staysession.api.response.StaySessionResponse;
//import com.lifeos.backend.task.api.response.TaskResponse;
//import com.lifeos.backend.task.domain.enums.TaskStatus;
//import lombok.RequiredArgsConstructor;
//import org.springframework.stereotype.Component;
//
//import java.time.LocalDate;
//import java.util.List;
//import java.util.UUID;
//
//@Component
//@RequiredArgsConstructor
//public class DailyScoreCalculator {
//
//    private final DailyScoreExplanationComposer dailyScoreExplanationComposer;
//
//    public DailyScore calculate(
//            UUID userId,
//            LocalDate date,
//            List<TaskResponse> relevantTasks,
//            List<ScheduleOccurrenceResponse> schedules,
//            List<StaySessionResponse> staySessions
//    ) {
//        long completedTasks = relevantTasks.stream()
//                .filter(task -> task.getStatus() == TaskStatus.COMPLETED)
//                .count();
//
//        int totalTasks = relevantTasks.size();
//        int totalPlannedBlocks = schedules.size();
//        int totalStaySessions = staySessions.size();
//
//        int completionScore = calculateCompletionScore(completedTasks, totalTasks);
//        int structureScore = calculateStructureScore(totalPlannedBlocks, totalStaySessions);
//        int overallScore = calculateOverallScore(completionScore, structureScore);
//
//        String scoreExplanation = dailyScoreExplanationComposer.compose(
//                completedTasks,
//                totalTasks,
//                totalPlannedBlocks,
//                totalStaySessions,
//                completionScore,
//                structureScore,
//                overallScore
//        );
//
//        DailyScore score = new DailyScore();
//        score.setUserId(userId);
//        score.setScoreDate(date);
//        score.setCompletionScore(completionScore);
//        score.setStructureScore(structureScore);
//        score.setOverallScore(overallScore);
//        score.setCompletedTasks((int) completedTasks);
//        score.setTotalTasks(totalTasks);
//        score.setTotalPlannedBlocks(totalPlannedBlocks);
//        score.setTotalStaySessions(totalStaySessions);
//        score.setScoreExplanation(scoreExplanation);
//
//        return score;
//    }
//
//    private int calculateCompletionScore(long completedTasks, int totalTasks) {
//        if (totalTasks <= 0) {
//            return 0;
//        }
//
//        return (int) Math.round((completedTasks * 100.0) / totalTasks);
//    }
//
//    private int calculateStructureScore(int totalPlannedBlocks, int totalStaySessions) {
//        return Math.min(totalPlannedBlocks * 20 + totalStaySessions * 10, 100);
//    }
//
//    private int calculateOverallScore(int completionScore, int structureScore) {
//        return (int) Math.round((completionScore + structureScore) / 2.0);
//    }
//}