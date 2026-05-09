package com.lifeos.backend.timeline.application;

import com.lifeos.backend.timeline.application.TimelineDayQueryService.TimelineDayEntry;
import com.lifeos.backend.timeline.application.TimelineDayQueryService.TimelineDayQueryResult;
import com.lifeos.backend.timeline.application.TimelineSummaryCalculator.TimelineSummary;
import com.lifeos.backend.timeline.domain.entity.TimelineEntry;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/**
 * Assembles product-level Timeline day view from ledger query result.
 *
 * This stays in application layer.
 * Later, API mappers can convert this to response DTOs.
 */
@Component
@RequiredArgsConstructor
public class TimelineDayAssembler {

    private final TimelineSummaryCalculator summaryCalculator;

    public TimelineDayView assemble(TimelineDayQueryResult queryResult) {
        if (queryResult == null) {
            throw new IllegalArgumentException("TimelineDayQueryResult is required");
        }

        List<TimelineDayItem> items = queryResult.entries()
                .stream()
                .map(this::toItem)
                .toList();

        TimelineSummary summary = summaryCalculator.calculate(queryResult.entries());

        return new TimelineDayView(
                queryResult.userId(),
                queryResult.date(),
                queryResult.zoneId().getId(),
                items,
                summary
        );
    }

    private TimelineDayItem toItem(TimelineDayEntry dayEntry) {
        TimelineEntry entry = dayEntry.entry();

        return new TimelineDayItem(
                entry.getId(),
                entry.getUserId(),

                entry.getEntryType().name(),
                entry.getSourceType().name(),
                entry.getAnchorType().name(),

                entry.getSourceId(),
                entry.getSourceTemplateId(),
                entry.getSourceOccurrenceId(),

                dayEntry.anchor().effectiveStartAt(),
                dayEntry.anchor().effectiveEndAt(),
                dayEntry.anchor().effectiveStartLocal(),
                dayEntry.anchor().effectiveEndLocal(),

                entry.getTitleSnapshot(),
                entry.getSubtitleSnapshot(),
                entry.getCategorySnapshot(),
                entry.getStatusSnapshot(),
                entry.getBadgeSnapshot(),
                entry.getMetadataJson(),

                dayEntry.anchor().clippedStart(),
                dayEntry.anchor().clippedEnd(),
                dayEntry.anchor().startsBeforeDay(),
                dayEntry.anchor().endsAfterDay(),
                dayEntry.anchor().spansMultipleDays(),
                dayEntry.anchor().visibleDurationMinutes()
        );
    }

    public record TimelineDayView(
            UUID userId,
            LocalDate date,
            String timezone,
            List<TimelineDayItem> items,
            TimelineSummary summary
    ) {
    }

    public record TimelineDayItem(
            UUID id,
            UUID userId,

            String entryType,
            String sourceType,
            String anchorType,

            UUID sourceId,
            UUID sourceTemplateId,
            UUID sourceOccurrenceId,

            java.time.Instant effectiveStartAt,
            java.time.Instant effectiveEndAt,
            java.time.LocalDateTime effectiveStartLocal,
            java.time.LocalDateTime effectiveEndLocal,

            String title,
            String subtitle,
            String category,
            String status,
            String badge,
            String metadataJson,

            boolean clippedStart,
            boolean clippedEnd,
            boolean startsBeforeDay,
            boolean endsAfterDay,
            boolean spansMultipleDays,
            long visibleDurationMinutes
    ) {
    }
}