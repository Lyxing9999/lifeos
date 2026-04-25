package com.lifeos.backend.summary.application;

import com.lifeos.backend.common.exception.NotFoundException;
import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.financial.api.response.FinancialEventResponse;
import com.lifeos.backend.financial.application.FinancialSummaryService;
import com.lifeos.backend.schedule.api.response.ScheduleOccurrenceResponse;
import com.lifeos.backend.schedule.application.ScheduleService;
import com.lifeos.backend.staysession.api.response.StaySessionResponse;
import com.lifeos.backend.staysession.application.StaySessionService;
import com.lifeos.backend.summary.api.response.DailySummaryResponse;
import com.lifeos.backend.summary.domain.DailySummary;
import com.lifeos.backend.summary.domain.DailySummaryRepository;
import com.lifeos.backend.task.api.response.TaskResponse;
import com.lifeos.backend.task.application.TaskService;
import com.lifeos.backend.task.domain.TaskFilterType;
import com.lifeos.backend.task.domain.TaskStatus;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class DailySummaryService {

    private final DailySummaryRepository repository;
    private final TaskService taskService;
    private final ScheduleService scheduleService;
    private final StaySessionService staySessionService;
    private final UserTimeService userTimeService;
    private final FinancialSummaryService financialSummaryService;

    public DailySummaryResponse generate(UUID userId, LocalDate date) {
        List<TaskResponse> relevantTasks = taskService.getRelevantTasksByUserAndDay(
                userId,
                date,
                TaskFilterType.ALL
        );

        List<ScheduleOccurrenceResponse> schedules =
                scheduleService.getOccurrencesByUserIdAndDay(userId, date);

        List<StaySessionResponse> staySessions =
                staySessionService.getByUserIdAndDay(userId, date);

        ZoneId zoneId = userTimeService.getUserZoneId(userId);

        List<FinancialEventResponse> financialEvents =
                financialSummaryService.getFinancialEventsForDay(userId, date, zoneId);

        StaySessionResponse topPlaceStay = staySessions.stream()
                .max(Comparator.comparingLong(StaySessionResponse::getDurationMinutes))
                .orElse(null);

        String topPlaceName = topPlaceStay != null ? topPlaceStay.getPlaceName() : "No dominant place";
        long topPlaceDurationMinutes = topPlaceStay != null ? topPlaceStay.getDurationMinutes() : 0L;

        long completedTasks = relevantTasks.stream()
                .filter(task -> task.getStatus() == TaskStatus.COMPLETED)
                .count();

        long totalTasks = relevantTasks.size();
        long totalPlannedBlocks = schedules.size();
        long totalStaySessions = staySessions.size();

        String financialSentence = financialSummaryService.buildDailySpendingSentence(financialEvents);

        String summaryText = buildSummaryText(
                topPlaceName,
                completedTasks,
                totalTasks,
                totalPlannedBlocks,
                totalStaySessions,
                financialSentence
        );

        String scoreExplanationText = buildScoreExplanationText(
                completedTasks,
                totalTasks,
                totalPlannedBlocks,
                totalStaySessions
        );

        String optionalInsight = buildOptionalInsight(topPlaceName, topPlaceDurationMinutes);

        repository.findByUserIdAndSummaryDate(userId, date)
                .ifPresent(repository::delete);

        DailySummary summary = new DailySummary();
        summary.setUserId(userId);
        summary.setSummaryDate(date);
        summary.setSummaryText(summaryText);
        summary.setTopPlaceName(topPlaceName);
        summary.setTotalTasks(totalTasks);
        summary.setCompletedTasks(completedTasks);
        summary.setTotalPlannedBlocks(totalPlannedBlocks);
        summary.setTotalStaySessions(totalStaySessions);
        summary.setScoreExplanationText(scoreExplanationText);
        summary.setOptionalInsight(optionalInsight);

        DailySummary saved = repository.save(summary);

        log.info(
                "daily_summary_generated userId={} date={} totalTasks={} completedTasks={} totalPlannedBlocks={} totalStaySessions={} topPlace={}",
                userId,
                date,
                totalTasks,
                completedTasks,
                totalPlannedBlocks,
                totalStaySessions,
                topPlaceName
        );

        return toResponse(saved);
    }

    public DailySummaryResponse get(UUID userId, LocalDate date) {
        DailySummary summary = repository.findByUserIdAndSummaryDate(userId, date)
                .orElseThrow(() -> new NotFoundException("Daily summary not found"));
        return toResponse(summary);
    }

    public void delete(UUID userId, LocalDate date) {
        DailySummary summary = repository.findByUserIdAndSummaryDate(userId, date)
                .orElseThrow(() -> new NotFoundException("Daily summary not found"));

        repository.delete(summary);

        log.info("daily_summary_deleted userId={} date={}", userId, date);
    }

    private String buildSummaryText(
            String topPlaceName,
            long completedTasks,
            long totalTasks,
            long totalPlannedBlocks,
            long totalStaySessions,
            String financialSentence
    ) {
        String base = "You spent most of your time at " + topPlaceName
                + ", completed " + completedTasks + " of " + totalTasks + " tasks, and had "
                + totalPlannedBlocks + " planned blocks with "
                + totalStaySessions + " stay sessions.";

        if (financialSentence == null || financialSentence.isBlank()) {
            return base;
        }

        return base + " " + financialSentence;
    }

    private String buildScoreExplanationText(
            long completedTasks,
            long totalTasks,
            long totalPlannedBlocks,
            long totalStaySessions
    ) {
        int completionScore = totalTasks <= 0
                ? 0
                : (int) Math.round((completedTasks * 100.0) / totalTasks);

        int structureScore = Math.min((int) totalPlannedBlocks * 20 + (int) totalStaySessions * 10, 100);
        int overallScore = (int) Math.round((completionScore + structureScore) / 2.0);

        return "Scores came from completion " + completionScore
                + " and structure " + structureScore
                + ", resulting in overall " + overallScore + ".";
    }

    private String buildOptionalInsight(String topPlaceName, long topPlaceDurationMinutes) {
        return "Your strongest place signal today was "
                + topPlaceName
                + " for "
                + topPlaceDurationMinutes
                + " minutes.";
    }

    private DailySummaryResponse toResponse(DailySummary summary) {
        return DailySummaryResponse.builder()
                .id(summary.getId())
                .userId(summary.getUserId())
                .summaryDate(summary.getSummaryDate())
                .summaryText(summary.getSummaryText())
                .topPlaceName(summary.getTopPlaceName())
                .totalTasks(summary.getTotalTasks())
                .completedTasks(summary.getCompletedTasks())
                .totalPlannedBlocks(summary.getTotalPlannedBlocks())
                .totalStaySessions(summary.getTotalStaySessions())
                .scoreExplanationText(summary.getScoreExplanationText())
                .optionalInsight(summary.getOptionalInsight())
                .build();
    }
}