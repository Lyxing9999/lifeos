package com.lifeos.backend.timeline.application;

import com.lifeos.backend.common.exception.NotFoundException;
import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.timeline.domain.entity.TimelineEntry;
import com.lifeos.backend.timeline.domain.enums.TimelineAnchorType;
import com.lifeos.backend.timeline.domain.enums.TimelineEntryType;
import com.lifeos.backend.timeline.domain.enums.TimelineSourceType;
import com.lifeos.backend.timeline.domain.repository.TimelineEntryRepository;
import com.lifeos.backend.timeline.domain.service.TimelineSnapshotBuilder;
import com.lifeos.backend.timeline.domain.service.TimelineSnapshotBuilder.TimelineEntrySnapshotCommand;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * Timeline ledger write service.
 *
 * Rule:
 * - Other modules do NOT write TimelineEntry directly.
 * - Task/Schedule/Finance/Stay publish events.
 * - Timeline listeners call this service.
 *
 * This service guarantees:
 * - snapshot-based history
 * - idempotent ingestion by dedupeKey
 * - safe duplicate handling
 * - no dependency back into Task/Schedule internals
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class TimelineIngestionService {

    private final TimelineEntryRepository timelineEntryRepository;
    private final TimelineSnapshotBuilder snapshotBuilder;
    private final UserTimeService userTimeService;

    /**
     * Idempotent ingestion.
     *
     * If the same dedupeKey already exists, returns the existing TimelineEntry
     * instead of creating a duplicate.
     */
    @Transactional
    public TimelineIngestionResult ingest(IngestTimelineEntryCommand command) {
        validate(command);

        ZoneId zoneId = resolveZoneId(command.userId(), command.timezone());

        TimelineEntrySnapshotCommand snapshotCommand =
                new TimelineEntrySnapshotCommand(
                        command.userId(),

                        command.entryType(),
                        command.sourceType(),
                        command.anchorType(),

                        command.sourceId(),
                        command.sourceTemplateId(),
                        command.sourceOccurrenceId(),

                        command.startAt(),
                        command.endAt(),
                        zoneId,

                        command.titleSnapshot(),
                        command.subtitleSnapshot(),
                        command.categorySnapshot(),
                        command.statusSnapshot(),
                        command.badgeSnapshot(),
                        command.metadataJson(),

                        command.dedupeKey(),
                        command.sortOrder()
                );

        TimelineEntry entry = snapshotBuilder.build(snapshotCommand);
        String dedupeKey = entry.getDedupeKey();

        if (dedupeKey != null && timelineEntryRepository.existsByDedupeKey(dedupeKey)) {
            TimelineEntry existing = timelineEntryRepository.findByDedupeKey(dedupeKey)
                    .orElseThrow(() -> new IllegalStateException("Timeline dedupe lookup failed"));

            return TimelineIngestionResult.existing(existing);
        }

        try {
            TimelineEntry saved = timelineEntryRepository.save(entry);

            log.debug(
                    "timeline_entry_ingested userId={} entryType={} sourceType={} sourceId={} dedupeKey={}",
                    saved.getUserId(),
                    saved.getEntryType(),
                    saved.getSourceType(),
                    saved.getSourceId(),
                    saved.getDedupeKey()
            );

            return TimelineIngestionResult.created(saved);

        } catch (DataIntegrityViolationException ex) {
            /**
             * Handles rare race condition:
             * two event listeners/processes try to write the same dedupeKey.
             */
            if (dedupeKey != null) {
                return timelineEntryRepository.findByDedupeKey(dedupeKey)
                        .map(TimelineIngestionResult::existing)
                        .orElseThrow(() -> ex);
            }

            throw ex;
        }
    }

    /**
     * Batch ingestion for rebuild/backfill.
     *
     * Each command is idempotent.
     * A failed command does not stop the whole batch.
     */
    @Transactional
    public TimelineBatchIngestionResult ingestMany(List<IngestTimelineEntryCommand> commands) {
        if (commands == null || commands.isEmpty()) {
            return TimelineBatchIngestionResult.empty();
        }

        int scanned = 0;
        int created = 0;
        int existing = 0;
        int failed = 0;

        List<UUID> createdEntryIds = new ArrayList<>();
        List<UUID> existingEntryIds = new ArrayList<>();
        List<String> errors = new ArrayList<>();

        for (IngestTimelineEntryCommand command : commands) {
            scanned++;

            try {
                TimelineIngestionResult result = ingest(command);

                if (result.created()) {
                    created++;
                    createdEntryIds.add(result.entry().getId());
                } else {
                    existing++;
                    existingEntryIds.add(result.entry().getId());
                }

            } catch (Exception ex) {
                failed++;

                String error = "Failed to ingest timeline entry sourceType="
                        + safe(command == null ? null : command.sourceType())
                        + " sourceId="
                        + safe(command == null ? null : command.sourceId())
                        + " error="
                        + ex.getMessage();

                errors.add(error);
                log.error(error, ex);
            }
        }

        return new TimelineBatchIngestionResult(
                scanned,
                created,
                existing,
                failed,
                createdEntryIds,
                existingEntryIds,
                errors
        );
    }

    @Transactional(readOnly = true)
    public TimelineEntry getById(UUID timelineEntryId) {
        if (timelineEntryId == null) {
            throw new IllegalArgumentException("timelineEntryId is required");
        }

        return timelineEntryRepository.findById(timelineEntryId)
                .orElseThrow(() -> new NotFoundException("Timeline entry not found"));
    }

    @Transactional
    public TimelineEntry hide(UUID userId, UUID timelineEntryId) {
        TimelineEntry entry = findOwnedEntry(userId, timelineEntryId);
        entry.hide();
        return timelineEntryRepository.save(entry);
    }

    @Transactional
    public TimelineEntry restore(UUID userId, UUID timelineEntryId) {
        TimelineEntry entry = findOwnedEntry(userId, timelineEntryId);
        entry.restoreVisible();
        return timelineEntryRepository.save(entry);
    }

    @Transactional
    public TimelineEntry softDelete(UUID userId, UUID timelineEntryId) {
        TimelineEntry entry = findOwnedEntry(userId, timelineEntryId);
        entry.softDelete();
        return timelineEntryRepository.save(entry);
    }

    private TimelineEntry findOwnedEntry(UUID userId, UUID timelineEntryId) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }

        TimelineEntry entry = getById(timelineEntryId);

        if (!userId.equals(entry.getUserId())) {
            throw new NotFoundException("Timeline entry not found");
        }

        return entry;
    }

    private ZoneId resolveZoneId(UUID userId, String timezone) {
        if (timezone != null && !timezone.isBlank()) {
            try {
                return ZoneId.of(timezone.trim());
            } catch (Exception ex) {
                log.warn(
                        "Invalid timeline timezone={} for userId={}, falling back to user timezone",
                        timezone,
                        userId
                );
            }
        }

        return userTimeService.getUserZoneId(userId);
    }

    private void validate(IngestTimelineEntryCommand command) {
        if (command == null) {
            throw new IllegalArgumentException("IngestTimelineEntryCommand is required");
        }

        if (command.userId() == null) {
            throw new IllegalArgumentException("userId is required");
        }

        if (command.entryType() == null) {
            throw new IllegalArgumentException("entryType is required");
        }

        if (command.sourceType() == null) {
            throw new IllegalArgumentException("sourceType is required");
        }

        if (command.startAt() == null) {
            throw new IllegalArgumentException("startAt is required");
        }

        if (command.endAt() != null && !command.endAt().isAfter(command.startAt())) {
            throw new IllegalArgumentException("endAt must be after startAt");
        }

        if (command.titleSnapshot() == null || command.titleSnapshot().isBlank()) {
            throw new IllegalArgumentException("titleSnapshot is required");
        }
    }

    private String safe(Object value) {
        return value == null ? "" : value.toString();
    }

    public record IngestTimelineEntryCommand(
            UUID userId,

            TimelineEntryType entryType,
            TimelineSourceType sourceType,
            TimelineAnchorType anchorType,

            UUID sourceId,
            UUID sourceTemplateId,
            UUID sourceOccurrenceId,

            Instant startAt,
            Instant endAt,
            String timezone,

            String titleSnapshot,
            String subtitleSnapshot,
            String categorySnapshot,
            String statusSnapshot,
            String badgeSnapshot,
            String metadataJson,

            String dedupeKey,
            Integer sortOrder
    ) {
    }

    public record TimelineIngestionResult(
            boolean created,
            TimelineEntry entry
    ) {
        public static TimelineIngestionResult created(TimelineEntry entry) {
            return new TimelineIngestionResult(true, entry);
        }

        public static TimelineIngestionResult existing(TimelineEntry entry) {
            return new TimelineIngestionResult(false, entry);
        }
    }

    public record TimelineBatchIngestionResult(
            int scanned,
            int created,
            int existing,
            int failed,
            List<UUID> createdEntryIds,
            List<UUID> existingEntryIds,
            List<String> errors
    ) {
        public static TimelineBatchIngestionResult empty() {
            return new TimelineBatchIngestionResult(
                    0,
                    0,
                    0,
                    0,
                    List.of(),
                    List.of(),
                    List.of()
            );
        }
    }
}