package com.lifeos.backend.today.application;

import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.schedule.application.query.ScheduleOccurrenceQueryService;
import com.lifeos.backend.schedule.domain.entity.ScheduleOccurrence;
//import com.lifeos.backend.score.api.response.DailyScoreResponse;
//import com.lifeos.backend.score.application.DailyScoreService;
//import com.lifeos.backend.summary.api.response.DailySummaryResponse;
//import com.lifeos.backend.summary.application.DailySummaryService;
import com.lifeos.backend.task.application.query.TaskInstanceQueryService;
import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.timeline.api.response.TimelineDayResponse;
import com.lifeos.backend.timeline.application.TimelineDayAssembler;
import com.lifeos.backend.timeline.application.TimelineDayQueryService;
import com.lifeos.backend.timeline.infrastructure.mapper.TimelineEntryMapper;
import com.lifeos.backend.today.api.response.TodayContextResponse;
import com.lifeos.backend.today.api.response.TodayCountsResponse;
import com.lifeos.backend.today.api.response.TodayCurrentFocusResponse;
import com.lifeos.backend.today.api.response.TodayScheduleSectionResponse;
import com.lifeos.backend.today.api.response.TodayTaskSectionResponse;
import com.lifeos.backend.today.api.response.TodayWorkspaceResponse;
import com.lifeos.backend.user.api.response.UserResponse;
import com.lifeos.backend.user.application.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class TodayWorkspaceService {

    private final UserService userService;
    private final UserTimeService userTimeService;

    private final TaskInstanceQueryService taskInstanceQueryService;
    private final ScheduleOccurrenceQueryService scheduleOccurrenceQueryService;

    private final TimelineDayQueryService timelineDayQueryService;
    private final TimelineDayAssembler timelineDayAssembler;
    private final TimelineEntryMapper timelineEntryMapper;
//
//    private final DailySummaryService dailySummaryService;
//    private final DailyScoreService dailyScoreService;

    private final TodayTaskSectionAssembler taskSectionAssembler;
    private final TodayScheduleSectionAssembler scheduleSectionAssembler;
    private final TodayCurrentFocusResolver currentFocusResolver;
    private final TodayGreetingService greetingService;

    public TodayWorkspaceResponse getWorkspace(UUID userId, LocalDate date) {
        validateUserId(userId);

        ZoneId zoneId = userTimeService.getUserZoneId(userId);
        LocalDate userToday = Instant.now().atZone(zoneId).toLocalDate();
        LocalDate requestedDate = date == null ? userToday : date;
        LocalDateTime userNowLocal = Instant.now().atZone(zoneId).toLocalDateTime();

        UserResponse user = userService.getProfile(userId);

        List<TaskInstance> scheduledToday = taskInstanceQueryService.getByScheduledDate(
                userId,
                requestedDate
        );

        List<TaskInstance> overdue = taskInstanceQueryService.getOverdue(userId);

        List<TaskInstance> inbox = taskInstanceQueryService.getInbox(userId);

        List<TaskInstance> completedToday = taskInstanceQueryService.getCompletedForDay(
                userId,
                requestedDate
        );

        List<ScheduleOccurrence> visibleSchedule =
                scheduleOccurrenceQueryService.getVisibleOccurrencesForDay(
                        userId,
                        requestedDate
                );

        TodayTaskSectionResponse taskSections = taskSectionAssembler.assemble(
                scheduledToday,
                overdue,
                inbox,
                completedToday
        );

        TodayScheduleSectionResponse scheduleSections = scheduleSectionAssembler.assemble(
                visibleSchedule,
                requestedDate,
                userToday,
                userNowLocal
        );

        TimelineDayResponse timelinePreview = buildTimelinePreview(userId, requestedDate);
//
//        DailySummaryResponse summary = safeSummary(userId, requestedDate);
//        DailyScoreResponse score = safeScore(userId, requestedDate);

        TodayCountsResponse counts = buildCounts(
                taskSections,
                scheduleSections,
                timelinePreview
        );

        TodayCurrentFocusResponse currentFocus = currentFocusResolver.resolve(
                taskSections,
                scheduleSections
        );

        String greeting = greetingService.generate(
                user == null ? null : user.getName(),
                userNowLocal,
                counts
        );

        TodayContextResponse context = buildContext(
                requestedDate,
                userToday,
                userNowLocal,
                zoneId
        );

        log.info(
                "today_workspace_built userId={} date={} timezone={} openTasks={} scheduleBlocks={} focusType={}",
                userId,
                requestedDate,
                zoneId,
                counts.getOpenTasks(),
                counts.getVisibleScheduleBlocks(),
                currentFocus.getFocusType()
        );

        return TodayWorkspaceResponse.builder()
                .userId(userId)
                .date(requestedDate)
                .user(user)
                .context(context)
                .greeting(greeting)
                .currentFocus(currentFocus)
                .tasks(taskSections)
                .schedule(scheduleSections)
                .timelinePreview(timelinePreview)
//                .summary(summary)
//                .score(score)
                .counts(counts)
                .build();
    }

    private TimelineDayResponse buildTimelinePreview(UUID userId, LocalDate date) {
        try {
            var queryResult = timelineDayQueryService.getDay(userId, date);
            var view = timelineDayAssembler.assemble(queryResult);
            return timelineEntryMapper.toDayResponse(view);
        } catch (Exception ex) {
            log.warn("Failed to build timeline preview userId={} date={}", userId, date, ex);
            return TimelineDayResponse.builder()
                    .userId(userId)
                    .date(date)
                    .items(List.of())
                    .build();
        }
    }

//    private DailySummaryResponse safeSummary(UUID userId, LocalDate date) {
//        try {
//            return dailySummaryService.generate(userId, date);
//        } catch (Exception ex) {
//            log.warn("Failed to build today summary userId={} date={}", userId, date, ex);
//            return null;
//        }
//    }
//
//    private DailyScoreResponse safeScore(UUID userId, LocalDate date) {
//        try {
//            return dailyScoreService.generate(userId, date);
//        } catch (Exception ex) {
//            log.warn("Failed to build today score userId={} date={}", userId, date, ex);
//            return null;
//        }
//    }

    private TodayCountsResponse buildCounts(
            TodayTaskSectionResponse tasks,
            TodayScheduleSectionResponse schedule,
            TimelineDayResponse timelinePreview
    ) {
        int overdue = safeInt(tasks.getOverdueCount());
        int dueToday = safeInt(tasks.getDueTodayCount());
        int inbox = safeInt(tasks.getInboxCount());
        int done = safeInt(tasks.getCompletedTodayCount());
        int open = safeInt(tasks.getTotalOpenCount());

        int visibleSchedule = safeInt(schedule.getVisibleTodayCount());
        int activeSchedule = safeInt(schedule.getActiveNowCount());
        int upcomingSchedule = safeInt(schedule.getUpcomingTodayCount());
        int expiredSchedule = safeInt(schedule.getExpiredTodayCount());

        int timelineEntries = timelinePreview == null || timelinePreview.getItems() == null
                ? 0
                : timelinePreview.getItems().size();

        return TodayCountsResponse.builder()
                .openTasks(open)
                .overdueTasks(overdue)
                .dueTodayTasks(dueToday)
                .inboxTasks(inbox)
                .completedTodayTasks(done)

                .visibleScheduleBlocks(visibleSchedule)
                .activeScheduleBlocks(activeSchedule)
                .upcomingScheduleBlocks(upcomingSchedule)
                .expiredScheduleBlocks(expiredSchedule)

                .timelineEntries(timelineEntries)
                .build();
    }

    private TodayContextResponse buildContext(
            LocalDate requestedDate,
            LocalDate userToday,
            LocalDateTime userNowLocal,
            ZoneId zoneId
    ) {
        boolean viewingToday = requestedDate.equals(userToday);
        boolean viewingPast = requestedDate.isBefore(userToday);
        boolean viewingFuture = requestedDate.isAfter(userToday);

        return TodayContextResponse.builder()
                .date(requestedDate)
                .userToday(userToday)
                .userNowLocal(userNowLocal)
                .timezone(zoneId.getId())
                .viewingToday(viewingToday)
                .viewingPast(viewingPast)
                .viewingFuture(viewingFuture)
                .dayPhase(resolveDayPhase(userNowLocal))
                .build();
    }

    private String resolveDayPhase(LocalDateTime userNowLocal) {
        int hour = userNowLocal == null ? 9 : userNowLocal.getHour();

        if (hour >= 5 && hour < 12) {
            return "MORNING";
        }

        if (hour >= 12 && hour < 17) {
            return "AFTERNOON";
        }

        if (hour >= 17 && hour < 22) {
            return "EVENING";
        }

        return "NIGHT";
    }

    private int safeInt(Integer value) {
        return value == null ? 0 : value;
    }

    private void validateUserId(UUID userId) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }
    }
}