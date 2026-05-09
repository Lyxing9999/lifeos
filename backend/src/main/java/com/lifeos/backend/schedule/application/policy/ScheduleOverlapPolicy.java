package com.lifeos.backend.schedule.application.policy;

import com.lifeos.backend.schedule.domain.entity.ScheduleOccurrence;
import com.lifeos.backend.schedule.domain.enums.ScheduleBlockType;
import com.lifeos.backend.schedule.domain.enums.ScheduleOccurrenceStatus;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Policy for schedule overlap/conflict decisions.
 *
 * This does not query database.
 * Pass existing overlapping occurrences from ScheduleOccurrenceRepository
 * or ScheduleAvailabilityQueryService.
 */
@Component
public class ScheduleOverlapPolicy {

    public OverlapDecision canCreate(
            LocalDateTime startDateTime,
            LocalDateTime endDateTime,
            List<ScheduleOccurrence> existingOverlaps
    ) {
        return canCreate(
                startDateTime,
                endDateTime,
                existingOverlaps,
                false
        );
    }

    /**
     * @param allowSoftOverlap true means warning only, not blocked.
     */
    public OverlapDecision canCreate(
            LocalDateTime startDateTime,
            LocalDateTime endDateTime,
            List<ScheduleOccurrence> existingOverlaps,
            boolean allowSoftOverlap
    ) {
        TimeWindowValidation validation = validateTimeWindow(
                startDateTime,
                endDateTime
        );

        if (!validation.valid()) {
            return OverlapDecision.blocked(validation.reason(), List.of());
        }

        List<ScheduleOccurrence> blocking = blockingOverlaps(existingOverlaps);

        if (blocking.isEmpty()) {
            return OverlapDecision.allowed("No schedule overlap");
        }

        if (allowSoftOverlap) {
            return OverlapDecision.allowedWithWarning(
                    "Schedule overlaps with existing block(s)",
                    blocking
            );
        }

        return OverlapDecision.blocked(
                "Schedule overlaps with existing block(s)",
                blocking
        );
    }

    public OverlapDecision canReschedule(
            UUID occurrenceId,
            LocalDateTime targetStartDateTime,
            LocalDateTime targetEndDateTime,
            List<ScheduleOccurrence> existingOverlaps
    ) {
        TimeWindowValidation validation = validateTimeWindow(
                targetStartDateTime,
                targetEndDateTime
        );

        if (!validation.valid()) {
            return OverlapDecision.blocked(validation.reason(), List.of());
        }

        List<ScheduleOccurrence> blocking = blockingOverlaps(existingOverlaps)
                .stream()
                .filter(occurrence -> occurrenceId == null
                        || !occurrenceId.equals(occurrence.getId()))
                .toList();

        if (blocking.isEmpty()) {
            return OverlapDecision.allowed("No schedule overlap");
        }

        return OverlapDecision.blocked(
                "Target time overlaps with existing block(s)",
                blocking
        );
    }

    public List<ScheduleOccurrence> blockingOverlaps(
            List<ScheduleOccurrence> overlaps
    ) {
        if (overlaps == null || overlaps.isEmpty()) {
            return List.of();
        }

        return overlaps.stream()
                .filter(this::blocksTime)
                .toList();
    }

    public boolean blocksTime(ScheduleOccurrence occurrence) {
        if (occurrence == null || occurrence.getStatus() == null) {
            return false;
        }

        return occurrence.getStatus() == ScheduleOccurrenceStatus.PLANNED
                || occurrence.getStatus() == ScheduleOccurrenceStatus.ACTIVE
                || occurrence.getStatus() == ScheduleOccurrenceStatus.EXPIRED;
    }

    /**
     * Future rule:
     * Some block types may be allowed to overlap softly.
     *
     * Example:
     * - FLEXIBLE can overlap as a weak suggestion
     * - BREAK can overlap if user allows
     */
    public boolean isSoftOverlapType(ScheduleBlockType type) {
        return type == ScheduleBlockType.FLEXIBLE
                || type == ScheduleBlockType.BREAK
                || type == ScheduleBlockType.OTHER;
    }

    public TimeWindowValidation validateTimeWindow(
            LocalDateTime startDateTime,
            LocalDateTime endDateTime
    ) {
        if (startDateTime == null || endDateTime == null) {
            return TimeWindowValidation.invalid(
                    "startDateTime and endDateTime are required"
            );
        }

        if (!startDateTime.isBefore(endDateTime)) {
            return TimeWindowValidation.invalid(
                    "startDateTime must be before endDateTime"
            );
        }

        return TimeWindowValidation.ok();
    }

    public record OverlapDecision(
            boolean allowed,
            boolean warning,
            String reason,
            List<ScheduleOccurrence> conflicts
    ) {
        public static OverlapDecision allowed(String reason) {
            return new OverlapDecision(true, false, reason, List.of());
        }

        public static OverlapDecision allowedWithWarning(
                String reason,
                List<ScheduleOccurrence> conflicts
        ) {
            return new OverlapDecision(true, true, reason, conflicts);
        }

        public static OverlapDecision blocked(
                String reason,
                List<ScheduleOccurrence> conflicts
        ) {
            return new OverlapDecision(false, false, reason, conflicts);
        }

        public boolean hasConflicts() {
            return conflicts != null && !conflicts.isEmpty();
        }
    }

    public record TimeWindowValidation(
            boolean valid,
            String reason
    ) {
        public static TimeWindowValidation ok() {
            return new TimeWindowValidation(true, null);
        }

        public static TimeWindowValidation invalid(String reason) {
            return new TimeWindowValidation(false, reason);
        }
    }
}