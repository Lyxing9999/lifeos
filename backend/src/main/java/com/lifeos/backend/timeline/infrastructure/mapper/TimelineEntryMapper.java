package com.lifeos.backend.timeline.infrastructure.mapper;

import com.lifeos.backend.timeline.api.response.TimelineDayResponse;
import com.lifeos.backend.timeline.api.response.TimelineEntryResponse;
import com.lifeos.backend.timeline.api.response.TimelineSummaryResponse;
import com.lifeos.backend.timeline.application.TimelineDayAssembler.TimelineDayItem;
import com.lifeos.backend.timeline.application.TimelineDayAssembler.TimelineDayView;
import com.lifeos.backend.timeline.application.TimelineSummaryCalculator.TimelineSummary;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class TimelineEntryMapper {

    public TimelineDayResponse toDayResponse(TimelineDayView view) {
        if (view == null) {
            return null;
        }

        return TimelineDayResponse.builder()
                .userId(view.userId())
                .date(view.date())
                .timezone(view.timezone())
                .summary(toSummaryResponse(view.summary()))
                .items(toEntryResponses(view.items()))
                .build();
    }

    public List<TimelineEntryResponse> toEntryResponses(List<TimelineDayItem> items) {
        if (items == null) {
            return List.of();
        }

        return items.stream()
                .map(this::toEntryResponse)
                .toList();
    }

    public TimelineEntryResponse toEntryResponse(TimelineDayItem item) {
        if (item == null) {
            return null;
        }

        return TimelineEntryResponse.builder()
                .id(item.id())
                .userId(item.userId())

                .entryType(item.entryType())
                .sourceType(item.sourceType())
                .anchorType(item.anchorType())

                .sourceId(item.sourceId())
                .sourceTemplateId(item.sourceTemplateId())
                .sourceOccurrenceId(item.sourceOccurrenceId())

                .effectiveStartAt(item.effectiveStartAt())
                .effectiveEndAt(item.effectiveEndAt())
                .effectiveStartLocal(item.effectiveStartLocal())
                .effectiveEndLocal(item.effectiveEndLocal())

                .title(item.title())
                .subtitle(item.subtitle())
                .category(item.category())
                .status(item.status())
                .badge(item.badge())
                .metadataJson(item.metadataJson())

                .clippedStart(item.clippedStart())
                .clippedEnd(item.clippedEnd())
                .startsBeforeDay(item.startsBeforeDay())
                .endsAfterDay(item.endsAfterDay())
                .spansMultipleDays(item.spansMultipleDays())
                .visibleDurationMinutes(item.visibleDurationMinutes())
                .build();
    }

    public TimelineSummaryResponse toSummaryResponse(TimelineSummary summary) {
        if (summary == null) {
            return null;
        }

        return TimelineSummaryResponse.builder()
                .totalEntries(summary.totalEntries())

                .totalTaskEntries(summary.totalTaskEntries())
                .completedTasks(summary.completedTasks())
                .missedTasks(summary.missedTasks())
                .skippedTasks(summary.skippedTasks())

                .totalScheduleEntries(summary.totalScheduleEntries())
                .expiredScheduleBlocks(summary.expiredScheduleBlocks())
                .cancelledScheduleBlocks(summary.cancelledScheduleBlocks())

                .totalStayEntries(summary.totalStayEntries())
                .totalLocationEntries(summary.totalLocationEntries())
                .totalFinancialEntries(summary.totalFinancialEntries())

                .totalVisibleSpanMinutes(summary.totalVisibleSpanMinutes())
                .build();
    }
}