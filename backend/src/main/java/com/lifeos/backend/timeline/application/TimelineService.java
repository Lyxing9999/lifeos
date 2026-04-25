package com.lifeos.backend.timeline.application;

import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.common.util.ZoneDateUtils;
import com.lifeos.backend.financial.api.response.FinancialEventResponse;
import com.lifeos.backend.financial.application.FinancialEventService;
import com.lifeos.backend.financial.application.FinancialSummaryService;
import com.lifeos.backend.location.domain.LocationLogRepository;
import com.lifeos.backend.schedule.api.response.ScheduleOccurrenceResponse;
import com.lifeos.backend.schedule.application.ScheduleService;
import com.lifeos.backend.staysession.api.response.StaySessionResponse;
import com.lifeos.backend.staysession.application.StaySessionService;
import com.lifeos.backend.task.api.response.TaskResponse;
import com.lifeos.backend.task.application.TaskService;
import com.lifeos.backend.task.domain.TaskFilterType;
import com.lifeos.backend.timeline.dto.TimelineDayResponse;
import com.lifeos.backend.timeline.dto.TimelineFinancialLiteResponse;
import com.lifeos.backend.timeline.dto.TimelineFinancialSummaryResponse;
import com.lifeos.backend.timeline.dto.TimelineItemResponse;
import com.lifeos.backend.timeline.dto.TimelineSummaryResponse;
import com.lifeos.backend.timeline.dto.TimelineTaskLiteResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class TimelineService {

    private final TaskService taskService;
    private final ScheduleService scheduleService;
    private final StaySessionService staySessionService;
    private final LocationLogRepository locationLogRepository;
    private final UserTimeService userTimeService;
    private final FinancialEventService financialEventService;
    private final FinancialSummaryService financialSummaryService;
    private final TaskTimelineItemMapper taskTimelineItemMapper;

    public TimelineDayResponse getDay(UUID userId, LocalDate date) {
        ZoneId zoneId = userTimeService.getUserZoneId(userId);

        List<TaskResponse> relevantTasks = taskService.getRelevantTasksByUserAndDay(
                userId,
                date,
                TaskFilterType.ALL
        );

        List<ScheduleOccurrenceResponse> schedules = scheduleService.getOccurrencesByUserIdAndDay(userId, date)
                .stream()
                .sorted(Comparator.comparing(ScheduleOccurrenceResponse::getStartDateTime))
                .toList();

        List<StaySessionResponse> staySessions = staySessionService.getByUserIdAndDay(userId, date)
                .stream()
                .sorted(Comparator.comparing(StaySessionResponse::getStartTime))
                .toList();

        long totalLocationLogs = locationLogRepository.findByUserIdAndRecordedAtBetween(
                userId,
                ZoneDateUtils.startOfDayUtc(date, zoneId),
                ZoneDateUtils.endOfDayUtc(date, zoneId)
        ).size();

        List<TimelineTaskLiteResponse> taskLites = relevantTasks.stream()
                .sorted(taskLiteComparator())
                .map(task -> TimelineTaskLiteResponse.builder()
                        .id(task.getId())
                        .title(task.getTitle())
                        .status(task.getStatus())
                        .taskMode(task.getTaskMode())
                        .priority(task.getPriority())
                        .progressPercent(task.getProgressPercent())
                        .category(task.getCategory())
                        .dueDate(task.getDueDate())
                        .dueDateTime(task.getDueDateTime())
                        .completedAt(task.getCompletedAt())
                        .linkedScheduleBlockId(task.getLinkedScheduleBlockId())
                        .tags(task.getTags() != null
                                ? task.getTags().stream().map(tag -> tag.getName()).toList()
                                : List.of())
                        .build())
                .toList();

        long completedTasks = relevantTasks.stream()
                .filter(task -> task.getStatus() != null && task.getStatus().name().equals("COMPLETED"))
                .count();

        StaySessionResponse topPlaceStay = staySessions.stream()
                .max(Comparator.comparingLong(StaySessionResponse::getDurationMinutes))
                .orElse(null);

        List<FinancialEventResponse> financialEventsRaw =
                financialEventService.getByUserIdAndDay(userId, date, zoneId.toString());

        List<TimelineFinancialLiteResponse> financialEvents = financialEventsRaw.stream()
                .sorted(Comparator.comparing(FinancialEventResponse::getPaidAt))
                .map(item -> TimelineFinancialLiteResponse.builder()
                        .id(item.getId())
                        .amount(item.getAmount())
                        .currency(item.getCurrency())
                        .merchantName(item.getMerchantName())
                        .financialEventType(item.getFinancialEventType())
                        .category(item.getCategory())
                        .paidAt(item.getPaidAt())
                        .build())
                .toList();

        BigDecimal totalOutgoing = financialSummaryService.totalOutgoing(financialEventsRaw);

        TimelineFinancialSummaryResponse financialSummary = TimelineFinancialSummaryResponse.builder()
                .totalFinancialEvents(financialEvents.size())
                .totalOutgoingAmount(totalOutgoing)
                .build();

        List<TimelineItemResponse> items = buildUnifiedItems(
                date,
                relevantTasks,
                schedules,
                staySessions,
                financialEventsRaw,
                zoneId
        );

        log.info(
                "timeline_day_built userId={} date={} timezone={} tasks={} schedules={} staySessions={} locationLogs={} financialEvents={} mergedItems={}",
                userId,
                date,
                zoneId,
                taskLites.size(),
                schedules.size(),
                staySessions.size(),
                totalLocationLogs,
                financialEvents.size(),
                items.size()
        );

        TimelineSummaryResponse summary = TimelineSummaryResponse.builder()
                .totalLocationLogs(totalLocationLogs)
                .totalStaySessions(staySessions.size())
                .totalTasks(taskLites.size())
                .completedTasks(completedTasks)
                .totalPlannedBlocks(schedules.size())
                .topPlaceName(topPlaceStay != null ? topPlaceStay.getPlaceName() : "No dominant place")
                .topPlaceDurationMinutes(topPlaceStay != null ? topPlaceStay.getDurationMinutes() : 0L)
                .build();

        return TimelineDayResponse.builder()
                .userId(userId)
                .date(date)
                .summary(summary)
                .items(items)
                .tasks(taskLites)
                .schedules(schedules)
                .staySessions(staySessions)
                .financialSummary(financialSummary)
                .financialEvents(financialEvents)
                .build();
    }

    private List<TimelineItemResponse> buildUnifiedItems(
            LocalDate date,
            List<TaskResponse> relevantTasks,
            List<ScheduleOccurrenceResponse> schedules,
            List<StaySessionResponse> staySessions,
            List<FinancialEventResponse> financialEventsRaw,
            ZoneId zoneId
    ) {
        List<TimelineItemResponse> items = new ArrayList<>();

        items.addAll(
                schedules.stream()
                        .map(item -> TimelineItemResponse.builder()
                                .itemType("SCHEDULE")
                                .itemId(item.getScheduleBlockId())
                                .title(item.getTitle())
                                .subtitle(item.getType() != null ? item.getType().name() : null)
                                .startDateTime(item.getStartDateTime())
                                .endDateTime(item.getEndDateTime())
                                .badge("Schedule")
                                .status(null)
                                .build())
                        .toList()
        );

        items.addAll(
                relevantTasks.stream()
                        .map(task -> taskTimelineItemMapper.toTimelineItem(task, zoneId, date))
                        .flatMap(java.util.Optional::stream)
                        .toList()
        );

        items.addAll(
                staySessions.stream()
                        .map(item -> TimelineItemResponse.builder()
                                .itemType("STAY")
                                .itemId(item.getId())
                                .title(item.getPlaceName())
                                .subtitle(item.getPlaceType())
                                .startDateTime(item.getStartTime() != null
                                        ? item.getStartTime().atZone(zoneId).toLocalDateTime()
                                        : null)
                                .endDateTime(item.getEndTime() != null
                                        ? item.getEndTime().atZone(zoneId).toLocalDateTime()
                                        : null)
                                .badge("Place")
                                .status(item.getMatchedPlaceSource())
                                .build())
                        .toList()
        );

        items.addAll(
                financialEventsRaw.stream()
                        .map(item -> TimelineItemResponse.builder()
                                .itemType("FINANCIAL")
                                .itemId(item.getId())
                                .title(item.getMerchantName())
                                .subtitle(item.getAmount() + " " + item.getCurrency())
                                .startDateTime(item.getPaidAt() != null
                                        ? item.getPaidAt().atZone(zoneId).toLocalDateTime()
                                        : null)
                                .endDateTime(null)
                                .badge("Spend")
                                .status(item.getFinancialEventType() != null
                                        ? item.getFinancialEventType().name()
                                        : null)
                                .build())
                        .toList()
        );

        return items.stream()
                .sorted(Comparator.comparing(
                        TimelineItemResponse::getStartDateTime,
                        Comparator.nullsLast(LocalDateTime::compareTo)
                ))
                .toList();
    }

    private Comparator<TaskResponse> taskLiteComparator() {
        return Comparator
                .comparing((TaskResponse task) -> task.getTaskMode() == null || !"URGENT".equals(task.getTaskMode().name()))
                .thenComparing((TaskResponse task) -> task.getDueDateTime() == null)
                .thenComparing(TaskResponse::getDueDateTime, Comparator.nullsLast(LocalDateTime::compareTo))
                .thenComparing((TaskResponse task) -> task.getDueDate() == null)
                .thenComparing(TaskResponse::getDueDate, Comparator.nullsLast(LocalDate::compareTo))
                .thenComparing(TaskResponse::getTitle, Comparator.nullsLast(String::compareToIgnoreCase));
    }
}