package com.lifeos.backend.schedule.application.policy;

import com.lifeos.backend.schedule.domain.entity.ScheduleOccurrence;
import com.lifeos.backend.schedule.domain.enums.ScheduleOccurrenceStatus;
import com.lifeos.backend.schedule.domain.valueobject.AvailabilityWindow;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Policy for deciding whether a time window is available.
 *
 * This does not query database.
 * Pass conflicts or availability windows from ScheduleAvailabilityQueryService.
 */
@Component
public class ScheduleAvailabilityPolicy {

    public AvailabilityDecision canUseWindow(
            LocalDateTime startDateTime,
            LocalDateTime endDateTime,
            List<ScheduleOccurrence> conflicts
    ) {
        WindowValidation validation = validateWindow(startDateTime, endDateTime);

        if (!validation.valid()) {
            return AvailabilityDecision.no(validation.reason(), List.of());
        }

        List<ScheduleOccurrence> blockingConflicts = blockingConflicts(conflicts);

        if (!blockingConflicts.isEmpty()) {
            return AvailabilityDecision.no(
                    "Time window is not available",
                    blockingConflicts
            );
        }

        return AvailabilityDecision.yes("Time window is available");
    }

    public AvailabilityDecision canFitInAvailableWindows(
            long requiredMinutes,
            List<AvailabilityWindow> availabilityWindows
    ) {
        if (requiredMinutes <= 0) {
            return AvailabilityDecision.no(
                    "requiredMinutes must be positive",
                    List.of()
            );
        }

        if (availabilityWindows == null || availabilityWindows.isEmpty()) {
            return AvailabilityDecision.no(
                    "No availability windows found",
                    List.of()
            );
        }

        boolean canFit = availabilityWindows.stream()
                .anyMatch(window -> window.canFitMinutes(requiredMinutes));

        if (!canFit) {
            return AvailabilityDecision.no(
                    "No availability window can fit " + requiredMinutes + " minutes",
                    List.of()
            );
        }

        return AvailabilityDecision.yes(
                "At least one availability window can fit " + requiredMinutes + " minutes"
        );
    }

    public List<ScheduleOccurrence> blockingConflicts(
            List<ScheduleOccurrence> conflicts
    ) {
        if (conflicts == null || conflicts.isEmpty()) {
            return List.of();
        }

        return conflicts.stream()
                .filter(this::blocksAvailability)
                .toList();
    }

    public boolean blocksAvailability(ScheduleOccurrence occurrence) {
        if (occurrence == null || occurrence.getStatus() == null) {
            return false;
        }

        return occurrence.getStatus() == ScheduleOccurrenceStatus.PLANNED
                || occurrence.getStatus() == ScheduleOccurrenceStatus.ACTIVE
                || occurrence.getStatus() == ScheduleOccurrenceStatus.EXPIRED;
    }

    public WindowValidation validateWindow(
            LocalDateTime startDateTime,
            LocalDateTime endDateTime
    ) {
        if (startDateTime == null || endDateTime == null) {
            return WindowValidation.invalid(
                    "startDateTime and endDateTime are required"
            );
        }

        if (!startDateTime.isBefore(endDateTime)) {
            return WindowValidation.invalid(
                    "startDateTime must be before endDateTime"
            );
        }

        return WindowValidation.ok();
    }

    public record AvailabilityDecision(
            boolean available,
            String reason,
            List<ScheduleOccurrence> conflicts
    ) {
        public static AvailabilityDecision yes(String reason) {
            return new AvailabilityDecision(true, reason, List.of());
        }

        public static AvailabilityDecision no(
                String reason,
                List<ScheduleOccurrence> conflicts
        ) {
            return new AvailabilityDecision(false, reason, conflicts);
        }
    }

    public record WindowValidation(
            boolean valid,
            String reason
    ) {
        public static WindowValidation ok() {
            return new WindowValidation(true, null);
        }

        public static WindowValidation invalid(String reason) {
            return new WindowValidation(false, reason);
        }
    }
}