package com.lifeos.backend.timeline.domain.service;

import com.lifeos.backend.timeline.domain.entity.TimelineEntry;
import com.lifeos.backend.timeline.domain.enums.TimelineAnchorType;
import com.lifeos.backend.timeline.domain.enums.TimelineEntryType;
import com.lifeos.backend.timeline.domain.enums.TimelineSourceType;
import com.lifeos.backend.timeline.domain.enums.TimelineVisibility;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.time.ZoneId;
import java.util.Objects;
import java.util.UUID;

/**
 * Builds immutable-ish TimelineEntry snapshots.
 *
 * TimelineEntry must store snapshot text so past truth does not change
 * when source data changes later.
 */
@Component
public class TimelineSnapshotBuilder {

    public TimelineEntry build(TimelineEntrySnapshotCommand command) {
        validate(command);

        ZoneId zoneId = command.zoneId();

        TimelineEntry entry = new TimelineEntry();

        entry.setUserId(command.userId());

        entry.setEntryType(command.entryType());
        entry.setSourceType(command.sourceType());
        entry.setAnchorType(resolveAnchorType(command.anchorType(), command.startAt(), command.endAt()));
        entry.setVisibility(TimelineVisibility.VISIBLE);

        entry.setDedupeKey(resolveDedupeKey(command));

        entry.setSourceId(command.sourceId());
        entry.setSourceTemplateId(command.sourceTemplateId());
        entry.setSourceOccurrenceId(command.sourceOccurrenceId());

        entry.setStartAt(command.startAt());
        entry.setEndAt(command.endAt());

        entry.setTimezone(zoneId.getId());
        entry.setStartDateTimeLocal(command.startAt().atZone(zoneId).toLocalDateTime());
        entry.setTimelineDate(command.startAt().atZone(zoneId).toLocalDate());

        if (command.endAt() != null) {
            entry.setEndDateTimeLocal(command.endAt().atZone(zoneId).toLocalDateTime());
        }

        entry.setTitleSnapshot(normalizeRequired(command.titleSnapshot(), "titleSnapshot"));
        entry.setSubtitleSnapshot(normalize(command.subtitleSnapshot()));
        entry.setCategorySnapshot(normalize(command.categorySnapshot()));
        entry.setStatusSnapshot(normalize(command.statusSnapshot()));
        entry.setBadgeSnapshot(normalize(command.badgeSnapshot()));
        entry.setMetadataJson(normalize(command.metadataJson()));
        entry.setSortOrder(command.sortOrder());

        entry.validate();

        return entry;
    }

    private TimelineAnchorType resolveAnchorType(
            TimelineAnchorType requested,
            Instant startAt,
            Instant endAt
    ) {
        if (requested != null) {
            return requested;
        }

        if (startAt != null && endAt != null && endAt.isAfter(startAt)) {
            return TimelineAnchorType.SPAN;
        }

        return TimelineAnchorType.POINT;
    }

    private String resolveDedupeKey(TimelineEntrySnapshotCommand command) {
        if (command.dedupeKey() != null && !command.dedupeKey().isBlank()) {
            return command.dedupeKey().trim();
        }

        if (command.sourceId() != null) {
            return command.entryType()
                    + ":"
                    + command.sourceType()
                    + ":"
                    + command.sourceId();
        }

        return command.entryType()
                + ":"
                + command.sourceType()
                + ":"
                + command.userId()
                + ":"
                + command.startAt()
                + ":"
                + Math.abs(Objects.hashCode(command.titleSnapshot()));
    }

    private void validate(TimelineEntrySnapshotCommand command) {
        if (command == null) {
            throw new IllegalArgumentException("TimelineEntrySnapshotCommand is required");
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

        if (command.zoneId() == null) {
            throw new IllegalArgumentException("zoneId is required");
        }

        normalizeRequired(command.titleSnapshot(), "titleSnapshot");
    }

    private String normalizeRequired(String value, String fieldName) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException(fieldName + " is required");
        }

        return value.trim();
    }

    private String normalize(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }

        return value.trim();
    }

    public record TimelineEntrySnapshotCommand(
            UUID userId,

            TimelineEntryType entryType,
            TimelineSourceType sourceType,
            TimelineAnchorType anchorType,

            UUID sourceId,
            UUID sourceTemplateId,
            UUID sourceOccurrenceId,

            Instant startAt,
            Instant endAt,
            ZoneId zoneId,

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
}