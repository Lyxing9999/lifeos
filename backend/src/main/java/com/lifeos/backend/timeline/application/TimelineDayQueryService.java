package com.lifeos.backend.timeline.application;

import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.timeline.domain.entity.TimelineEntry;
import com.lifeos.backend.timeline.domain.repository.TimelineEntryRepository;
import com.lifeos.backend.timeline.domain.service.TimelineAnchorResolver;
import com.lifeos.backend.timeline.domain.service.TimelineAnchorResolver.TimelineAnchor;
import com.lifeos.backend.timeline.domain.service.TimelineSortService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;
import java.util.UUID;

/**
 * Read-side service for Timeline day ledger.
 *
 * Important:
 * Uses overlap query for SPAN/ALL_DAY.
 * Does not dynamically ask Task/Schedule to rebuild history.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class TimelineDayQueryService {

    private final TimelineEntryRepository timelineEntryRepository;
    private final TimelineAnchorResolver anchorResolver;
    private final TimelineSortService sortService;
    private final UserTimeService userTimeService;

    public TimelineDayQueryResult getDay(UUID userId, LocalDate date) {
        validateUserId(userId);

        LocalDate targetDate = resolveDate(userId, date);
        ZoneId zoneId = userTimeService.getUserZoneId(userId);

        Instant dayStartAt = anchorResolver.dayStartAt(targetDate, zoneId);
        Instant dayEndAt = anchorResolver.dayEndAt(targetDate, zoneId);

        List<TimelineEntry> entries = timelineEntryRepository.findVisibleForDay(
                userId,
                dayStartAt,
                dayEndAt
        );

        List<TimelineDayEntry> dayEntries = sortService.sortChronologically(entries)
                .stream()
                .map(entry -> new TimelineDayEntry(
                        entry,
                        anchorResolver.resolve(entry, targetDate, zoneId)
                ))
                .filter(dayEntry -> dayEntry.anchor().visibleOnDate())
                .toList();

        return new TimelineDayQueryResult(
                userId,
                targetDate,
                zoneId,
                dayStartAt,
                dayEndAt,
                dayEntries
        );
    }

    private LocalDate resolveDate(UUID userId, LocalDate date) {
        if (date != null) {
            return date;
        }

        return Instant.now()
                .atZone(userTimeService.getUserZoneId(userId))
                .toLocalDate();
    }

    private void validateUserId(UUID userId) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }
    }

    public record TimelineDayQueryResult(
            UUID userId,
            LocalDate date,
            ZoneId zoneId,
            Instant dayStartAt,
            Instant dayEndAt,
            List<TimelineDayEntry> entries
    ) {
    }

    public record TimelineDayEntry(
            TimelineEntry entry,
            TimelineAnchor anchor
    ) {
    }
}