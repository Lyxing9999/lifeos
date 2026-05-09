package com.lifeos.backend.timeline.infrastructure.persistence;

import com.lifeos.backend.timeline.domain.entity.TimelineEntry;
import com.lifeos.backend.timeline.domain.enums.TimelineAnchorType;
import com.lifeos.backend.timeline.domain.enums.TimelineEntryType;
import com.lifeos.backend.timeline.domain.enums.TimelineSourceType;
import com.lifeos.backend.timeline.domain.enums.TimelineVisibility;
import com.lifeos.backend.timeline.domain.repository.TimelineEntryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
public class TimelineEntryRepositoryImpl implements TimelineEntryRepository {

    private final TimelineEntryJpaRepository jpaRepository;

    @Override
    public TimelineEntry save(TimelineEntry entry) {
        if (entry != null) {
            entry.validate();
        }

        return jpaRepository.save(entry);
    }

    @Override
    public List<TimelineEntry> saveAll(List<TimelineEntry> entries) {
        if (entries != null) {
            entries.forEach(TimelineEntry::validate);
        }

        return jpaRepository.saveAll(entries);
    }

    @Override
    public Optional<TimelineEntry> findById(UUID entryId) {
        return jpaRepository.findById(entryId);
    }

    @Override
    public Optional<TimelineEntry> findByDedupeKey(String dedupeKey) {
        if (dedupeKey == null || dedupeKey.isBlank()) {
            return Optional.empty();
        }

        return jpaRepository.findByDedupeKey(dedupeKey);
    }

    @Override
    public boolean existsByDedupeKey(String dedupeKey) {
        if (dedupeKey == null || dedupeKey.isBlank()) {
            return false;
        }

        return jpaRepository.existsByDedupeKey(dedupeKey);
    }

    @Override
    public List<TimelineEntry> findVisibleForDay(
            UUID userId,
            Instant dayStartAt,
            Instant dayEndAt
    ) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }

        if (dayStartAt == null || dayEndAt == null) {
            throw new IllegalArgumentException("dayStartAt and dayEndAt are required");
        }

        if (!dayStartAt.isBefore(dayEndAt)) {
            throw new IllegalArgumentException("dayStartAt must be before dayEndAt");
        }

        return jpaRepository.findVisibleForDay(
                userId,
                dayStartAt,
                dayEndAt,
                TimelineVisibility.VISIBLE,
                TimelineAnchorType.POINT,
                List.of(
                        TimelineAnchorType.SPAN,
                        TimelineAnchorType.ALL_DAY
                )
        );
    }

    @Override
    public List<TimelineEntry> findByUserIdAndTimelineDate(
            UUID userId,
            LocalDate timelineDate
    ) {
        return jpaRepository.findByUserIdAndTimelineDateOrderByStartAtAsc(
                userId,
                timelineDate
        );
    }

    @Override
    public List<TimelineEntry> findByUserIdAndSource(
            UUID userId,
            TimelineSourceType sourceType,
            UUID sourceId
    ) {
        return jpaRepository.findByUserIdAndSourceTypeAndSourceIdOrderByStartAtAsc(
                userId,
                sourceType,
                sourceId
        );
    }

    @Override
    public List<TimelineEntry> findByUserIdAndEntryType(
            UUID userId,
            TimelineEntryType entryType
    ) {
        return jpaRepository.findByUserIdAndEntryTypeOrderByStartAtAsc(
                userId,
                entryType
        );
    }

    @Override
    public void deleteById(UUID entryId) {
        jpaRepository.deleteById(entryId);
    }
}