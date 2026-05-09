package com.lifeos.backend.timeline.application;

import com.lifeos.backend.timeline.application.TimelineDayQueryService.TimelineDayEntry;
import com.lifeos.backend.timeline.domain.enums.TimelineEntryType;
import com.lifeos.backend.timeline.domain.enums.TimelineSourceType;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class TimelineSummaryCalculator {

    public TimelineSummary calculate(List<TimelineDayEntry> dayEntries) {
        List<TimelineDayEntry> safeEntries = dayEntries == null
                ? List.of()
                : dayEntries;

        long taskCount = countBySource(safeEntries, TimelineSourceType.TASK);
        long scheduleCount = countBySource(safeEntries, TimelineSourceType.SCHEDULE);
        long stayCount = countBySource(safeEntries, TimelineSourceType.STAY);
        long locationCount = countBySource(safeEntries, TimelineSourceType.LOCATION);
        long financialCount = countBySource(safeEntries, TimelineSourceType.FINANCIAL);

        long completedTasks = countByEntryType(safeEntries, TimelineEntryType.TASK_COMPLETED);
        long missedTasks = countByEntryType(safeEntries, TimelineEntryType.TASK_MISSED);
        long skippedTasks = countByEntryType(safeEntries, TimelineEntryType.TASK_SKIPPED);

        long expiredScheduleBlocks = countByEntryType(safeEntries, TimelineEntryType.SCHEDULE_EXPIRED);
        long cancelledScheduleBlocks = countByEntryType(safeEntries, TimelineEntryType.SCHEDULE_CANCELLED);

        long totalVisibleSpanMinutes = safeEntries.stream()
                .mapToLong(dayEntry -> dayEntry.anchor().visibleDurationMinutes())
                .sum();

        return new TimelineSummary(
                safeEntries.size(),

                taskCount,
                completedTasks,
                missedTasks,
                skippedTasks,

                scheduleCount,
                expiredScheduleBlocks,
                cancelledScheduleBlocks,

                stayCount,
                locationCount,
                financialCount,

                totalVisibleSpanMinutes
        );
    }

    private long countBySource(
            List<TimelineDayEntry> entries,
            TimelineSourceType sourceType
    ) {
        return entries.stream()
                .filter(dayEntry -> dayEntry.entry().getSourceType() == sourceType)
                .count();
    }

    private long countByEntryType(
            List<TimelineDayEntry> entries,
            TimelineEntryType entryType
    ) {
        return entries.stream()
                .filter(dayEntry -> dayEntry.entry().getEntryType() == entryType)
                .count();
    }

    public record TimelineSummary(
            int totalEntries,

            long totalTaskEntries,
            long completedTasks,
            long missedTasks,
            long skippedTasks,

            long totalScheduleEntries,
            long expiredScheduleBlocks,
            long cancelledScheduleBlocks,

            long totalStayEntries,
            long totalLocationEntries,
            long totalFinancialEntries,

            long totalVisibleSpanMinutes
    ) {
    }
}