package com.lifeos.backend.timeline.domain.entity;

import com.lifeos.backend.common.base.BaseEntity;
import com.lifeos.backend.timeline.domain.enums.TimelineAnchorType;
import com.lifeos.backend.timeline.domain.enums.TimelineEntryType;
import com.lifeos.backend.timeline.domain.enums.TimelineSourceType;
import com.lifeos.backend.timeline.domain.enums.TimelineVisibility;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * TimelineEntry = immutable-ish past truth ledger row.
 *
 * Important:
 * Timeline does not calculate history dynamically from Task/Schedule.
 * Timeline stores snapshots at the moment an event happens.
 *
 * Example:
 * If user renames "Gym" to "Workout" tomorrow,
 * today's TimelineEntry still says "Gym".
 */
@Entity
@Table(
        name = "timeline_entries",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_timeline_entries_dedupe_key",
                        columnNames = {"dedupe_key"}
                )
        },
        indexes = {
                @Index(name = "idx_timeline_entries_user_start", columnList = "user_id,start_at"),
                @Index(name = "idx_timeline_entries_user_visibility", columnList = "user_id,visibility"),
                @Index(name = "idx_timeline_entries_user_type", columnList = "user_id,entry_type"),
                @Index(name = "idx_timeline_entries_source", columnList = "source_type,source_id"),
                @Index(name = "idx_timeline_entries_day", columnList = "user_id,timeline_date"),
                @Index(name = "idx_timeline_entries_anchor", columnList = "anchor_type,start_at,end_at")
        }
)
@Getter
@Setter
public class TimelineEntry extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    /**
     * Product meaning.
     *
     * Example:
     * TASK_COMPLETED, SCHEDULE_EXPIRED, FINANCIAL_TRANSACTION.
     */
    @Enumerated(EnumType.STRING)
    @Column(name = "entry_type", nullable = false, length = 80)
    private TimelineEntryType entryType;

    /**
     * Source module.
     *
     * Example:
     * TASK, SCHEDULE, FINANCIAL.
     */
    @Enumerated(EnumType.STRING)
    @Column(name = "source_type", nullable = false, length = 50)
    private TimelineSourceType sourceType;

    /**
     * POINT, SPAN, or ALL_DAY.
     */
    @Enumerated(EnumType.STRING)
    @Column(name = "anchor_type", nullable = false, length = 50)
    private TimelineAnchorType anchorType = TimelineAnchorType.POINT;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    private TimelineVisibility visibility = TimelineVisibility.VISIBLE;

    /**
     * Idempotency key.
     *
     * Example:
     * TASK_COMPLETED:<taskInstanceId>
     * SCHEDULE_EXPIRED:<scheduleOccurrenceId>
     * FINANCIAL_TRANSACTION:<financialEventId>
     *
     * This prevents duplicate timeline rows if event listener runs twice.
     */
    @Column(name = "dedupe_key", length = 200)
    private String dedupeKey;

    /**
     * Main source row id.
     *
     * Task instance id, schedule occurrence id, financial event id, stay session id, etc.
     */
    @Column(name = "source_id")
    private UUID sourceId;

    /**
     * Optional source template id.
     *
     * Example:
     * TaskTemplate id or ScheduleTemplate id.
     */
    @Column(name = "source_template_id")
    private UUID sourceTemplateId;

    /**
     * Optional source occurrence id.
     *
     * Useful when sourceId is not directly occurrence-specific.
     */
    @Column(name = "source_occurrence_id")
    private UUID sourceOccurrenceId;

    /**
     * User-local primary date.
     *
     * For POINT: local date of startAt.
     * For SPAN: local date of startAt.
     * Querying SPAN across days must still use overlap query, not only this field.
     */
    @Column(name = "timeline_date")
    private LocalDate timelineDate;

    /**
     * Absolute start instant.
     *
     * POINT uses startAt only.
     * SPAN uses startAt + endAt.
     */
    @Column(name = "start_at", nullable = false)
    private Instant startAt;

    /**
     * Absolute end instant.
     *
     * Nullable for POINT.
     * Nullable for open-ended SPAN, for example active stay session.
     */
    @Column(name = "end_at")
    private Instant endAt;

    /**
     * User-local display start.
     *
     * Stored as snapshot for easy UI.
     */
    @Column(name = "start_date_time_local")
    private LocalDateTime startDateTimeLocal;

    /**
     * User-local display end.
     */
    @Column(name = "end_date_time_local")
    private LocalDateTime endDateTimeLocal;

    @Column(length = 80)
    private String timezone;

    /**
     * Snapshot fields.
     *
     * These must not depend on future source changes.
     */
    @Column(name = "title_snapshot", nullable = false, length = 300)
    private String titleSnapshot;

    @Column(name = "subtitle_snapshot", length = 500)
    private String subtitleSnapshot;

    @Column(name = "category_snapshot", length = 120)
    private String categorySnapshot;

    @Column(name = "status_snapshot", length = 120)
    private String statusSnapshot;

    /**
     * Optional badge for UI.
     *
     * Example:
     * Done, Schedule, Spend, Place.
     */
    @Column(name = "badge_snapshot", length = 80)
    private String badgeSnapshot;

    /**
     * Extra immutable snapshot info.
     *
     * JSON string for now.
     */
    @Column(name = "metadata_json", columnDefinition = "TEXT")
    private String metadataJson;

    /**
     * Optional sort override.
     */
    @Column(name = "sort_order")
    private Integer sortOrder;

    public boolean isVisible() {
        return visibility == TimelineVisibility.VISIBLE;
    }

    public boolean isHidden() {
        return visibility == TimelineVisibility.HIDDEN;
    }

    public boolean isDeleted() {
        return visibility == TimelineVisibility.DELETED;
    }

    public boolean isPoint() {
        return anchorType == TimelineAnchorType.POINT;
    }

    public boolean isSpan() {
        return anchorType == TimelineAnchorType.SPAN;
    }

    public boolean isAllDay() {
        return anchorType == TimelineAnchorType.ALL_DAY;
    }

    public boolean overlaps(Instant rangeStart, Instant rangeEnd) {
        if (rangeStart == null || rangeEnd == null || startAt == null) {
            return false;
        }

        if (!rangeStart.isBefore(rangeEnd)) {
            throw new IllegalArgumentException("rangeStart must be before rangeEnd");
        }

        if (anchorType == TimelineAnchorType.POINT) {
            return !startAt.isBefore(rangeStart) && startAt.isBefore(rangeEnd);
        }

        Instant safeEndAt = endAt == null ? rangeEnd : endAt;

        return startAt.isBefore(rangeEnd) && safeEndAt.isAfter(rangeStart);
    }

    public void hide() {
        this.visibility = TimelineVisibility.HIDDEN;
    }

    public void restoreVisible() {
        this.visibility = TimelineVisibility.VISIBLE;
    }

    public void softDelete() {
        this.visibility = TimelineVisibility.DELETED;
    }

    public void validate() {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }

        if (entryType == null) {
            throw new IllegalArgumentException("entryType is required");
        }

        if (sourceType == null) {
            throw new IllegalArgumentException("sourceType is required");
        }

        if (anchorType == null) {
            throw new IllegalArgumentException("anchorType is required");
        }

        if (visibility == null) {
            visibility = TimelineVisibility.VISIBLE;
        }

        if (startAt == null) {
            throw new IllegalArgumentException("startAt is required");
        }

        if (anchorType == TimelineAnchorType.SPAN
                && endAt != null
                && !endAt.isAfter(startAt)) {
            throw new IllegalArgumentException("endAt must be after startAt for SPAN");
        }

        if (titleSnapshot == null || titleSnapshot.isBlank()) {
            throw new IllegalArgumentException("titleSnapshot is required");
        }
    }
}