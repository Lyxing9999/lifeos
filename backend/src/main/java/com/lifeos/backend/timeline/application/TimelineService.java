package com.lifeos.backend.timeline.application;

import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.common.util.ZoneDateUtils;
import com.lifeos.backend.financial.api.response.FinancialEventResponse;
import com.lifeos.backend.financial.application.FinancialEventService;
import com.lifeos.backend.financial.application.FinancialSummaryService;
import com.lifeos.backend.location.domain.LocationLogRepository;
import com.lifeos.backend.schedule.api.response.ScheduleOccurrenceResponse;
import com.lifeos.backend.schedule.application.ScheduleQueryService;
import com.lifeos.backend.staysession.api.response.StaySessionResponse;
import com.lifeos.backend.staysession.application.StaySessionService;
import com.lifeos.backend.task.api.response.TaskResponse;
import com.lifeos.backend.task.application.TaskQueryService;
import com.lifeos.backend.timeline.domain.enums.TimelineItemType;
import com.lifeos.backend.timeline.dto.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class TimelineService {

        private final TaskQueryService taskQueryService;
        private final ScheduleQueryService scheduleQueryService;
        private final StaySessionService staySessionService;
        private final LocationLogRepository locationLogRepository;
        private final UserTimeService userTimeService;
        private final FinancialEventService financialEventService;
        private final FinancialSummaryService financialSummaryService;
        private final TaskTimelineItemMapper taskTimelineItemMapper;

        public TimelineDayResponse getDay(UUID userId, LocalDate date) {
                ZoneId zoneId = userTimeService.getUserZoneId(userId);

                // 1. FIRE ALL QUERIES CONCURRENTLY
                var tasksFuture = CompletableFuture.supplyAsync(() ->
                        taskQueryService.getDayTruthTasks(userId, date));

                var schedulesFuture = CompletableFuture.supplyAsync(() ->
                        scheduleQueryService.getOccurrencesForDay(userId, date));

                var staysFuture = CompletableFuture.supplyAsync(() ->
                        staySessionService.getByUserIdAndDay(userId, date));

                var locationFuture = CompletableFuture.supplyAsync(() ->
                        locationLogRepository.findByUserIdAndRecordedAtBetween(
                                userId, ZoneDateUtils.startOfDayUtc(date, zoneId), ZoneDateUtils.endOfDayUtc(date, zoneId)).size());

                var financeFuture = CompletableFuture.supplyAsync(() ->
                        financialEventService.getByUserIdAndDay(userId, date, zoneId.toString()));

                // 2. WAIT FOR ALL TO FINISH (Takes only as long as the slowest query)
                CompletableFuture.allOf(tasksFuture, schedulesFuture, staysFuture, locationFuture, financeFuture).join();

                // 3. EXTRACT THE DATA
                List<TaskResponse> relevantTasks = tasksFuture.join();
                List<ScheduleOccurrenceResponse> schedules = schedulesFuture.join();
                List<StaySessionResponse> staySessions = staysFuture.join();
                long totalLocationLogs = locationFuture.join();
                List<FinancialEventResponse> financialEventsRaw = financeFuture.join();

                // 4. PROCESS TASK LITES
                List<TimelineTaskLiteResponse> taskLites = relevantTasks.stream()
                        .sorted(taskLiteComparator())
                        .map(this::toTaskLite)
                        .toList();

                long completedTasks = relevantTasks.stream()
                        .filter(task -> task.getStatus() != null && task.getStatus().name().equals("COMPLETED"))
                        .count();

                // 5. PROCESS FINANCE LITES
                List<TimelineFinancialLiteResponse> financialEvents = financialEventsRaw.stream()
                        .sorted(Comparator.comparing(FinancialEventResponse::getPaidAt))
                        .map(this::toFinanceLite)
                        .toList();

                BigDecimal totalOutgoing = financialSummaryService.totalOutgoing(financialEventsRaw);

                // 6. BUILD UNIFIED CHRONOLOGICAL ITEMS
                List<TimelineItemResponse> items = buildUnifiedItems(
                        date, relevantTasks, schedules, staySessions, financialEventsRaw, zoneId);

                StaySessionResponse topPlaceStay = staySessions.stream()
                        .max(Comparator.comparingLong(StaySessionResponse::getDurationMinutes))
                        .orElse(null);

                log.info("timeline_day_built userId={} date={} items={}", userId, date, items.size());

                return TimelineDayResponse.builder()
                        .userId(userId)
                        .date(date)
                        .summary(TimelineSummaryResponse.builder()
                                .totalLocationLogs(totalLocationLogs)
                                .totalStaySessions(staySessions.size())
                                .totalTasks(taskLites.size())
                                .completedTasks(completedTasks)
                                .totalPlannedBlocks(schedules.size())
                                .topPlaceName(topPlaceStay != null ? topPlaceStay.getPlaceName() : "No dominant place")
                                .topPlaceDurationMinutes(topPlaceStay != null ? topPlaceStay.getDurationMinutes() : 0L)
                                .build())
                        .items(items)
                        .tasks(taskLites)
                        .schedules(schedules)
                        .staySessions(staySessions)
                        .financialSummary(TimelineFinancialSummaryResponse.builder()
                                .totalFinancialEvents(financialEvents.size())
                                .totalOutgoingAmount(totalOutgoing)
                                .build())
                        .financialEvents(financialEvents)
                        .build();
        }

        private List<TimelineItemResponse> buildUnifiedItems(
                LocalDate date, List<TaskResponse> tasks, List<ScheduleOccurrenceResponse> schedules,
                List<StaySessionResponse> stays, List<FinancialEventResponse> finances, ZoneId zoneId) {

                List<TimelineItemResponse> items = new ArrayList<>();

                Set<UUID> scheduleBlockIdsOnDay = schedules.stream()
                        .map(ScheduleOccurrenceResponse::getScheduleBlockId)
                        .collect(Collectors.toSet());

                // MAP SCHEDULES
                schedules.forEach(item -> items.add(TimelineItemResponse.builder()
                        .itemType(TimelineItemType.SCHEDULE.name())
                        .itemId(item.getScheduleBlockId())
                        .title(item.getTitle())
                        .subtitle(buildScheduleSubtitle(item, tasks))
                        .startDateTime(item.getStartDateTime())
                        .endDateTime(item.getEndDateTime())
                        .badge("Schedule")
                        .build()));

                // MAP TASKS (Excluding those hidden by schedules)
                tasks.stream()
                        .filter(task -> shouldShowStandaloneTaskItem(task, scheduleBlockIdsOnDay))
                        .map(task -> taskTimelineItemMapper.toTimelineItem(task, zoneId, date))
                        .flatMap(Optional::stream)
                        .forEach(items::add);

                // MAP STAYS
                stays.forEach(item -> items.add(TimelineItemResponse.builder()
                        .itemType(TimelineItemType.STAY.name())
                        .itemId(item.getId())
                        .title(item.getPlaceName())
                        .subtitle(item.getPlaceType())
                        .startDateTime(item.getStartTime() != null ? item.getStartTime().atZone(zoneId).toLocalDateTime() : null)
                        .endDateTime(item.getEndTime() != null ? item.getEndTime().atZone(zoneId).toLocalDateTime() : null)
                        .badge("Place")
                        .status(item.getMatchedPlaceSource())
                        .build()));

                // MAP FINANCES
                finances.forEach(item -> items.add(TimelineItemResponse.builder()
                        .itemType(TimelineItemType.FINANCIAL.name())
                        .itemId(item.getId())
                        .title(item.getMerchantName())
                        .subtitle(item.getAmount() + " " + item.getCurrency())
                        .startDateTime(item.getPaidAt() != null ? item.getPaidAt().atZone(zoneId).toLocalDateTime() : null)
                        .badge("Spend")
                        .status(item.getFinancialEventType() != null ? item.getFinancialEventType().name() : null)
                        .build()));

                // SORT EVERYTHING CHRONOLOGICALLY
                items.sort(Comparator.comparing(
                        TimelineItemResponse::getStartDateTime,
                        Comparator.nullsLast(LocalDateTime::compareTo)));

                return items;
        }

        private boolean shouldShowStandaloneTaskItem(TaskResponse task, Set<UUID> scheduleBlockIds) {
                if (task == null || task.getLinkedScheduleBlockId() == null) return true;
                return !scheduleBlockIds.contains(task.getLinkedScheduleBlockId());
        }

        private String buildScheduleSubtitle(ScheduleOccurrenceResponse schedule, List<TaskResponse> tasks) {
                String type = schedule.getType() != null ? schedule.getType().name() : "SCHEDULE";
                long linkedTaskCount = tasks.stream()
                        .filter(t -> schedule.getScheduleBlockId().equals(t.getLinkedScheduleBlockId()))
                        .count();
                if (linkedTaskCount <= 0) return type;
                return type + " • " + linkedTaskCount + " linked task" + (linkedTaskCount == 1 ? "" : "s");
        }

        private TimelineTaskLiteResponse toTaskLite(TaskResponse task) {
                return TimelineTaskLiteResponse.builder()
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
                        .tags(task.getTags() != null ? task.getTags().stream().map(t -> t.getName()).toList() : List.of())
                        .build();
        }

        private TimelineFinancialLiteResponse toFinanceLite(FinancialEventResponse item) {
                return TimelineFinancialLiteResponse.builder()
                        .id(item.getId())
                        .amount(item.getAmount())
                        .currency(item.getCurrency())
                        .merchantName(item.getMerchantName())
                        .financialEventType(item.getFinancialEventType())
                        .category(item.getCategory())
                        .paidAt(item.getPaidAt())
                        .build();
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