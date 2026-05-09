package com.lifeos.backend.timeline.infrastructure.persistence;

import com.lifeos.backend.timeline.domain.entity.TimelineEntry;
import com.lifeos.backend.timeline.domain.enums.TimelineAnchorType;
import com.lifeos.backend.timeline.domain.enums.TimelineEntryType;
import com.lifeos.backend.timeline.domain.enums.TimelineSourceType;
import com.lifeos.backend.timeline.domain.enums.TimelineVisibility;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.time.LocalDate;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface TimelineEntryJpaRepository extends JpaRepository<TimelineEntry, UUID> {

    Optional<TimelineEntry> findByDedupeKey(String dedupeKey);

    boolean existsByDedupeKey(String dedupeKey);

    List<TimelineEntry> findByUserIdAndTimelineDateOrderByStartAtAsc(
            UUID userId,
            LocalDate timelineDate
    );

    List<TimelineEntry> findByUserIdAndSourceTypeAndSourceIdOrderByStartAtAsc(
            UUID userId,
            TimelineSourceType sourceType,
            UUID sourceId
    );

    List<TimelineEntry> findByUserIdAndEntryTypeOrderByStartAtAsc(
            UUID userId,
            TimelineEntryType entryType
    );

    /**
     * Correct Timeline day query.
     *
     * POINT:
     * startAt >= dayStart AND startAt < dayEnd
     *
     * SPAN / ALL_DAY:
     * startAt < dayEnd AND (endAt IS NULL OR endAt > dayStart)
     *
     * This makes overnight spans appear on both days.
     */
    @Query("""
            select e
            from TimelineEntry e
            where e.userId = :userId
              and e.visibility = :visibility
              and (
                    (
                        e.anchorType = :pointType
                        and e.startAt >= :dayStartAt
                        and e.startAt < :dayEndAt
                    )
                    or
                    (
                        e.anchorType in :spanTypes
                        and e.startAt < :dayEndAt
                        and (e.endAt is null or e.endAt > :dayStartAt)
                    )
                  )
            order by e.startAt asc
            """)
    List<TimelineEntry> findVisibleForDay(
            @Param("userId") UUID userId,
            @Param("dayStartAt") Instant dayStartAt,
            @Param("dayEndAt") Instant dayEndAt,
            @Param("visibility") TimelineVisibility visibility,
            @Param("pointType") TimelineAnchorType pointType,
            @Param("spanTypes") Collection<TimelineAnchorType> spanTypes
    );
}