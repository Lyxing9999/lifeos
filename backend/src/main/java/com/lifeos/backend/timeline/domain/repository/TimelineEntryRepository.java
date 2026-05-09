package com.lifeos.backend.timeline.domain.repository;

import com.lifeos.backend.timeline.domain.entity.TimelineEntry;
import com.lifeos.backend.timeline.domain.enums.TimelineEntryType;
import com.lifeos.backend.timeline.domain.enums.TimelineSourceType;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface TimelineEntryRepository {

    TimelineEntry save(TimelineEntry entry);

    List<TimelineEntry> saveAll(List<TimelineEntry> entries);

    Optional<TimelineEntry> findById(UUID entryId);

    Optional<TimelineEntry> findByDedupeKey(String dedupeKey);

    boolean existsByDedupeKey(String dedupeKey);

    List<TimelineEntry> findVisibleForDay(
            UUID userId,
            Instant dayStartAt,
            Instant dayEndAt
    );

    List<TimelineEntry> findByUserIdAndTimelineDate(
            UUID userId,
            LocalDate timelineDate
    );

    List<TimelineEntry> findByUserIdAndSource(
            UUID userId,
            TimelineSourceType sourceType,
            UUID sourceId
    );

    List<TimelineEntry> findByUserIdAndEntryType(
            UUID userId,
            TimelineEntryType entryType
    );

    void deleteById(UUID entryId);
}