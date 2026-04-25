package com.lifeos.backend.today.application;

import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.financial.api.response.FinancialEventResponse;
import com.lifeos.backend.financial.application.FinancialEventService;
import com.lifeos.backend.financial.application.FinancialSummaryService;
import com.lifeos.backend.score.api.response.DailyScoreResponse;
import com.lifeos.backend.score.application.DailyScoreService;
import com.lifeos.backend.schedule.api.response.ScheduleOccurrenceResponse;
import com.lifeos.backend.schedule.application.ScheduleService;
import com.lifeos.backend.staysession.api.response.StaySessionResponse;
import com.lifeos.backend.staysession.application.StaySessionService;
import com.lifeos.backend.summary.api.response.DailySummaryResponse;
import com.lifeos.backend.summary.application.DailySummaryService;
import com.lifeos.backend.task.api.response.TaskResponse;
import com.lifeos.backend.task.application.TaskService;
import com.lifeos.backend.today.dto.TodayCurrentScheduleResponse;
import com.lifeos.backend.today.dto.TodayFinancialInsightResponse;
import com.lifeos.backend.today.dto.TodayPlaceInsightResponse;
import com.lifeos.backend.today.dto.TodayResponse;
import com.lifeos.backend.timeline.application.TimelineService;
import com.lifeos.backend.timeline.dto.TimelineDayResponse;
import com.lifeos.backend.user.api.response.UserResponse;
import com.lifeos.backend.user.application.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class TodayService {

    private final UserService userService;
    private final DailySummaryService dailySummaryService;
    private final DailyScoreService dailyScoreService;
    private final TimelineService timelineService;
    private final ScheduleService scheduleService;
    private final TaskService taskService;
    private final StaySessionService staySessionService;
    private final UserTimeService userTimeService;
    private final FinancialEventService financialEventService;
    private final FinancialSummaryService financialSummaryService;

    public TodayResponse get(UUID userId, LocalDate date) {
        UserResponse user = userService.getProfile(userId);

        // Always rebuild fresh while core day model is stabilizing
        DailySummaryResponse summary = dailySummaryService.generate(userId, date);
        DailyScoreResponse score = dailyScoreService.generate(userId, date);

        TimelineDayResponse timeline = timelineService.getDay(userId, date);

        ZoneId zoneId = userTimeService.getUserZoneId(userId);

        TodayCurrentScheduleResponse currentScheduleBlock = resolveCurrentScheduleBlock(userId, date, zoneId);
        TaskResponse topActiveTask = taskService.getTopActiveTask(userId, date);
        TodayPlaceInsightResponse topPlaceInsight = resolveTopPlaceInsight(userId, date);
        TodayFinancialInsightResponse financialInsight = resolveFinancialInsight(userId, date, zoneId);

        log.info(
                "today_overview_built userId={} date={} timezone={} relevantTasks={} currentTask={} currentSchedule={} topPlace={} financialEvents={}",
                userId,
                date,
                zoneId,
                timeline.getSummary() != null ? timeline.getSummary().getTotalTasks() : 0,
                topActiveTask != null ? topActiveTask.getTitle() : "NONE",
                currentScheduleBlock != null ? currentScheduleBlock.getTitle() : "NONE",
                topPlaceInsight != null ? topPlaceInsight.getPlaceName() : "NONE",
                financialInsight != null ? financialInsight.getTotalEvents() : 0
        );

        return TodayResponse.builder()
                .user(user)
                .date(date)
                .summary(summary)
                .score(score)
                .timeline(timeline)
                .currentScheduleBlock(currentScheduleBlock)
                .topActiveTask(topActiveTask)
                .topPlaceInsight(topPlaceInsight)
                .financialInsight(financialInsight)
                .build();
    }

    private TodayCurrentScheduleResponse resolveCurrentScheduleBlock(UUID userId, LocalDate date, ZoneId zoneId) {
        var nowLocal = Instant.now().atZone(zoneId).toLocalDateTime();

        List<ScheduleOccurrenceResponse> occurrences =
                scheduleService.getOccurrencesByUserIdAndDay(userId, date);

        ScheduleOccurrenceResponse active = occurrences.stream()
                .filter(item -> !nowLocal.isBefore(item.getStartDateTime()) && nowLocal.isBefore(item.getEndDateTime()))
                .findFirst()
                .orElse(occurrences.stream()
                        .min(Comparator.comparing(item -> Math.abs(
                                java.time.Duration.between(nowLocal, item.getStartDateTime()).toMinutes()
                        )))
                        .orElse(null));

        if (active == null) {
            return null;
        }

        boolean activeNow = !nowLocal.isBefore(active.getStartDateTime()) && nowLocal.isBefore(active.getEndDateTime());

        return TodayCurrentScheduleResponse.builder()
                .scheduleBlockId(active.getScheduleBlockId())
                .title(active.getTitle())
                .type(active.getType())
                .startDateTime(active.getStartDateTime())
                .endDateTime(active.getEndDateTime())
                .activeNow(activeNow)
                .build();
    }

    private TodayPlaceInsightResponse resolveTopPlaceInsight(UUID userId, LocalDate date) {
        List<StaySessionResponse> staySessions = staySessionService.getByUserIdAndDay(userId, date);

        StaySessionResponse top = staySessions.stream()
                .max(Comparator.comparingLong(StaySessionResponse::getDurationMinutes))
                .orElse(null);

        if (top == null) {
            return TodayPlaceInsightResponse.builder()
                    .placeName("No dominant place")
                    .placeType("OTHER")
                    .durationMinutes(0L)
                    .source("NONE")
                    .build();
        }

        return TodayPlaceInsightResponse.builder()
                .placeName(top.getPlaceName())
                .placeType(top.getPlaceType())
                .durationMinutes(top.getDurationMinutes())
                .source(top.getMatchedPlaceSource())
                .build();
    }

    private TodayFinancialInsightResponse resolveFinancialInsight(UUID userId, LocalDate date, ZoneId zoneId) {
        List<FinancialEventResponse> events =
                financialEventService.getByUserIdAndDay(userId, date, zoneId.toString());

        if (events.isEmpty()) {
            return TodayFinancialInsightResponse.builder()
                    .totalEvents(0)
                    .totalOutgoingAmount(BigDecimal.ZERO)
                    .latestMerchantName(null)
                    .latestAmount(null)
                    .latestCurrency(null)
                    .build();
        }

        BigDecimal totalOutgoing = financialSummaryService.totalOutgoing(events);
        FinancialEventResponse latest = financialSummaryService.latest(events);

        return TodayFinancialInsightResponse.builder()
                .totalEvents(events.size())
                .totalOutgoingAmount(totalOutgoing)
                .latestMerchantName(latest != null ? latest.getMerchantName() : null)
                .latestAmount(latest != null ? latest.getAmount() : null)
                .latestCurrency(latest != null ? latest.getCurrency() : null)
                .build();
    }
}