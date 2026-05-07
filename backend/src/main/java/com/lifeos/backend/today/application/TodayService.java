package com.lifeos.backend.today.application;

import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.score.api.response.DailyScoreResponse;
import com.lifeos.backend.score.application.DailyScoreService;
import com.lifeos.backend.schedule.api.response.ScheduleOccurrenceResponse;
import com.lifeos.backend.schedule.domain.ScheduleBlockType;
import com.lifeos.backend.staysession.api.response.StaySessionResponse;
import com.lifeos.backend.summary.api.response.DailySummaryResponse;
import com.lifeos.backend.summary.application.DailySummaryService;
import com.lifeos.backend.task.domain.enums.TaskStatus;
import com.lifeos.backend.timeline.application.TimelineService;
import com.lifeos.backend.timeline.dto.TimelineDayResponse;
import com.lifeos.backend.timeline.dto.TimelineTaskLiteResponse;
import com.lifeos.backend.today.dto.TodayCurrentScheduleResponse;
import com.lifeos.backend.today.dto.TodayPlaceInsightResponse;
import com.lifeos.backend.today.dto.TodayResponse;
import com.lifeos.backend.user.api.response.UserResponse;
import com.lifeos.backend.user.application.UserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executor;

@Service
@Slf4j
public class TodayService {

    private final UserService userService;
    private final DailySummaryService dailySummaryService;
    private final DailyScoreService dailyScoreService;
    private final TimelineService timelineService;
    private final UserTimeService userTimeService;
    private final Executor ioExecutor;

    public TodayService(
            UserService userService,
            DailySummaryService dailySummaryService,
            DailyScoreService dailyScoreService,
            TimelineService timelineService,
            UserTimeService userTimeService,
            @Qualifier("applicationTaskExecutor") Executor ioExecutor) {
        this.userService = userService;
        this.dailySummaryService = dailySummaryService;
        this.dailyScoreService = dailyScoreService;
        this.timelineService = timelineService;
        this.userTimeService = userTimeService;
        this.ioExecutor = ioExecutor;
    }

    public TodayResponse get(UUID userId, LocalDate date) {
        ZoneId zoneId = userTimeService.getUserZoneId(userId);

        // 1. CONCURRENT FETCHING (Using custom IO Executor + Graceful Degradation)
        var userFuture = CompletableFuture.supplyAsync(() -> userService.getProfile(userId), ioExecutor)
                .exceptionally(ex -> {
                    log.error("Failed to load user profile for userId={}", userId, ex);
                    return null; // Handle null in builder or throw if User is absolutely mandatory
                });

        var summaryFuture = CompletableFuture.supplyAsync(() -> dailySummaryService.generate(userId, date), ioExecutor)
                .exceptionally(ex -> {
                    log.error("Failed to load summary for userId={}", userId, ex);
                    return null; // Graceful degradation: Dashboard still loads without summary
                });

        var scoreFuture = CompletableFuture.supplyAsync(() -> dailyScoreService.generate(userId, date), ioExecutor)
                .exceptionally(ex -> {
                    log.error("Failed to load score for userId={}", userId, ex);
                    return null;
                });

        var timelineFuture = CompletableFuture.supplyAsync(() -> timelineService.getDay(userId, date), ioExecutor)
                .exceptionally(ex -> {
                    log.error("Failed to load timeline for userId={}", userId, ex);
                    // Return empty timeline using Lombok Builder to bypass constructor visibility
                    return TimelineDayResponse.builder().build();
                });

        CompletableFuture.allOf(userFuture, summaryFuture, scoreFuture, timelineFuture).join();

        UserResponse user = userFuture.join();
        DailySummaryResponse summary = summaryFuture.join();
        DailyScoreResponse score = scoreFuture.join();
        TimelineDayResponse timeline = timelineFuture.join();

        // 2. IN-MEMORY INSIGHT EXTRACTION (NPE Safe)
        TodayCurrentScheduleResponse currentSchedule = null;
        TimelineTaskLiteResponse topTask = null;
        TodayPlaceInsightResponse topPlace = null;
        String greeting = "Commander"; // Safe fallback

        if (timeline != null) {
            currentSchedule = extractCurrentSchedule(timeline.getSchedules(), date, zoneId);
            topTask = extractTopTask(timeline.getTasks(), currentSchedule);
            topPlace = extractTopPlace(timeline.getStaySessions());

            if (user != null) {
                greeting = generateContextualGreeting(user.getName(), zoneId, timeline.getTasks());
            }
        }

        log.info("today_dashboard_built userId={} date={} timezone={} tasks={} topTask={} currentSchedule={}",
                userId, date, zoneId,
                (timeline != null && timeline.getTasks() != null) ? timeline.getTasks().size() : 0,
                topTask != null ? topTask.getTitle() : "NONE",
                currentSchedule != null ? currentSchedule.getTitle() : "NONE"
        );

        return TodayResponse.builder()
                .user(user)
                .date(date)
                .contextualGreeting(greeting)
                .summary(summary)
                .score(score)
                .timeline(timeline)
                .currentScheduleBlock(currentSchedule)
                .topActiveTask(topTask)
                .topPlaceInsight(topPlace)
                .build();
    }

    // --- IN-MEMORY EXTRACTORS ---

    private TodayCurrentScheduleResponse extractCurrentSchedule(
            List<ScheduleOccurrenceResponse> schedules, LocalDate requestedDate, ZoneId zoneId) {

        if (schedules == null || schedules.isEmpty()) return null;

        LocalDate todayInUserZone = Instant.now().atZone(zoneId).toLocalDate();
        LocalDateTime nowLocal = Instant.now().atZone(zoneId).toLocalDateTime();

        // If viewing a future/past day, just show the first schedule of that day
        if (!requestedDate.equals(todayInUserZone)) {
            ScheduleOccurrenceResponse first = schedules.stream()
                    .min(Comparator.comparing(ScheduleOccurrenceResponse::getStartDateTime))
                    .orElse(null);
            if (first == null) return null;
            return mapToCurrentSchedule(first, false);
        }

        // Find what is active NOW
        ScheduleOccurrenceResponse activeNow = schedules.stream()
                .filter(s -> !nowLocal.isBefore(s.getStartDateTime()) && nowLocal.isBefore(s.getEndDateTime()))
                .findFirst()
                .orElse(null);

        if (activeNow != null) {
            return mapToCurrentSchedule(activeNow, true);
        }

        // If nothing active now, find the NEXT upcoming one today
        ScheduleOccurrenceResponse nextUpcoming = schedules.stream()
                .filter(s -> s.getStartDateTime().isAfter(nowLocal))
                .min(Comparator.comparing(ScheduleOccurrenceResponse::getStartDateTime))
                .orElse(null);

        if (nextUpcoming != null) {
            return mapToCurrentSchedule(nextUpcoming, false);
        }

        return null;
    }

    private TimelineTaskLiteResponse extractTopTask(
            List<TimelineTaskLiteResponse> tasks, TodayCurrentScheduleResponse currentSchedule) {
        if (tasks == null || tasks.isEmpty()) return null;
        return tasks.stream()
                .filter(t -> t.getStatus() != TaskStatus.COMPLETED && t.getStatus() != TaskStatus.CANCELLED)
                .filter(t -> currentSchedule == null || t.getLinkedScheduleBlockId() == null ||
                        !t.getLinkedScheduleBlockId().equals(currentSchedule.getScheduleBlockId()))
                .findFirst()
                .orElse(null);
    }

    private TodayPlaceInsightResponse extractTopPlace(List<StaySessionResponse> stays) {
        if (stays == null || stays.isEmpty()) {
            return TodayPlaceInsightResponse.builder()
                    .placeName("No dominant place")
                    .placeType("OTHER")
                    .durationMinutes(0L)
                    .source("NONE")
                    .build();
        }

        StaySessionResponse top = stays.stream()
                .max(Comparator.comparingLong(StaySessionResponse::getDurationMinutes))
                .orElse(null);

        return TodayPlaceInsightResponse.builder()
                .placeName(top.getPlaceName())
                .placeType(top.getPlaceType())
                .durationMinutes(top.getDurationMinutes())
                .source(top.getMatchedPlaceSource())
                .build();
    }

    private TodayCurrentScheduleResponse mapToCurrentSchedule(ScheduleOccurrenceResponse s, boolean isActiveNow) {
        return TodayCurrentScheduleResponse.builder()
                .scheduleBlockId(s.getScheduleBlockId())
                .title(s.getTitle())
                .type(s.getType())
                .startDateTime(s.getStartDateTime())
                .endDateTime(s.getEndDateTime())
                .activeNow(isActiveNow)
                .build();
    }

    // --- NEW PRODUCT FEATURE ---

    private String generateContextualGreeting(String userName, ZoneId zoneId, List<TimelineTaskLiteResponse> tasks) {
        int hour = Instant.now().atZone(zoneId).getHour();
        long pendingTasks = (tasks != null) ? tasks.stream().filter(t -> t.getStatus() != TaskStatus.COMPLETED).count() : 0;

        String firstName = userName != null ? userName.split(" ")[0] : "Commander";

        if (hour >= 5 && hour < 12) {
            return pendingTasks > 0 ? "Good morning, " + firstName + ". Let's attack the day." : "Good morning, " + firstName + ". A clear slate today.";
        } else if (hour >= 12 && hour < 17) {
            return pendingTasks > 0 ? "Keep the momentum going, " + firstName + "." : "Great afternoon, " + firstName + ".";
        } else if (hour >= 17 && hour < 22) {
            return pendingTasks == 0 ? "Excellent work today. Time to rest." : "Evening, " + firstName + ". Wrap up your final items.";
        } else {
            return "Late night, " + firstName + ". Prepare for tomorrow.";
        }
    }
}