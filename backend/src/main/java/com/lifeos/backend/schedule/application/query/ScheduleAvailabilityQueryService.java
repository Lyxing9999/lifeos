package com.lifeos.backend.schedule.application.query;

import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.schedule.domain.entity.ScheduleOccurrence;
import com.lifeos.backend.schedule.domain.enums.ScheduleOccurrenceStatus;
import com.lifeos.backend.schedule.domain.repository.ScheduleOccurrenceRepository;
import com.lifeos.backend.schedule.domain.valueobject.AvailabilityWindow;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

/**
 * Query service for free-time calculation.
 *
 * Schedule owns planned time structure, so it can answer:
 * "When is the user free?"
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ScheduleAvailabilityQueryService {

    private final ScheduleOccurrenceRepository occurrenceRepository;
    private final UserTimeService userTimeService;

    public List<AvailabilityWindow> getAvailabilityForDay(
            UUID userId,
            LocalDate date
    ) {
        return getAvailabilityForDay(
                userId,
                date,
                LocalTime.of(0, 0),
                LocalTime.of(23, 59),
                1
        );
    }

    public List<AvailabilityWindow> getAvailabilityForDay(
            UUID userId,
            LocalDate date,
            LocalTime dayStartTime,
            LocalTime dayEndTime,
            long minimumMinutes
    ) {
        validateUserId(userId);

        LocalDate targetDate = resolveUserDate(userId, date);

        LocalTime safeDayStart = dayStartTime == null
                ? LocalTime.of(0, 0)
                : dayStartTime;

        LocalTime safeDayEnd = dayEndTime == null
                ? LocalTime.of(23, 59)
                : dayEndTime;

        if (!safeDayStart.isBefore(safeDayEnd)) {
            throw new IllegalArgumentException("dayStartTime must be before dayEndTime");
        }

        long safeMinimumMinutes = Math.max(minimumMinutes, 1);

        LocalDateTime dayStart = targetDate.atTime(safeDayStart);
        LocalDateTime dayEnd = targetDate.atTime(safeDayEnd);

        List<ScheduleOccurrence> busyOccurrences = occurrenceRepository
                .findByUserIdAndScheduledDate(userId, targetDate)
                .stream()
                .filter(this::blocksAvailability)
                .sorted(Comparator.comparing(ScheduleOccurrence::getStartDateTime))
                .toList();

        List<BusyWindow> mergedBusyWindows = mergeBusyWindows(
                busyOccurrences,
                dayStart,
                dayEnd
        );

        return calculateFreeWindows(
                dayStart,
                dayEnd,
                mergedBusyWindows,
                safeMinimumMinutes
        );
    }

    public List<AvailabilityWindow> getAvailabilityBetween(
            UUID userId,
            LocalDateTime rangeStart,
            LocalDateTime rangeEnd,
            long minimumMinutes
    ) {
        validateUserId(userId);
        validateRange(rangeStart, rangeEnd);

        long safeMinimumMinutes = Math.max(minimumMinutes, 1);

        List<ScheduleOccurrence> busyOccurrences = occurrenceRepository
                .findOverlapping(userId, rangeStart, rangeEnd)
                .stream()
                .filter(this::blocksAvailability)
                .sorted(Comparator.comparing(ScheduleOccurrence::getStartDateTime))
                .toList();

        List<BusyWindow> mergedBusyWindows = mergeBusyWindows(
                busyOccurrences,
                rangeStart,
                rangeEnd
        );

        return calculateFreeWindows(
                rangeStart,
                rangeEnd,
                mergedBusyWindows,
                safeMinimumMinutes
        );
    }

    public boolean isAvailable(
            UUID userId,
            LocalDateTime startDateTime,
            LocalDateTime endDateTime
    ) {
        validateUserId(userId);
        validateRange(startDateTime, endDateTime);

        return occurrenceRepository.findOverlapping(
                        userId,
                        startDateTime,
                        endDateTime
                )
                .stream()
                .noneMatch(this::blocksAvailability);
    }

    public AvailabilityCheckResult checkAvailability(
            UUID userId,
            LocalDateTime startDateTime,
            LocalDateTime endDateTime
    ) {
        validateUserId(userId);
        validateRange(startDateTime, endDateTime);

        List<ScheduleOccurrence> conflicts = occurrenceRepository
                .findOverlapping(userId, startDateTime, endDateTime)
                .stream()
                .filter(this::blocksAvailability)
                .sorted(Comparator.comparing(ScheduleOccurrence::getStartDateTime))
                .toList();

        return new AvailabilityCheckResult(
                userId,
                startDateTime,
                endDateTime,
                conflicts.isEmpty(),
                conflicts
        );
    }

    private boolean blocksAvailability(ScheduleOccurrence occurrence) {
        if (occurrence == null || occurrence.getStatus() == null) {
            return false;
        }

        /**
         * These statuses mean the time was/is occupied.
         *
         * CANCELLED/SKIPPED/RESCHEDULED original occurrence should not block time.
         * Rescheduled target occurrence usually has sourceType RESCHEDULED,
         * but its status is PLANNED/ACTIVE, so it still blocks time.
         */
        return occurrence.getStatus() == ScheduleOccurrenceStatus.PLANNED
                || occurrence.getStatus() == ScheduleOccurrenceStatus.ACTIVE
                || occurrence.getStatus() == ScheduleOccurrenceStatus.EXPIRED;
    }

    private List<BusyWindow> mergeBusyWindows(
            List<ScheduleOccurrence> occurrences,
            LocalDateTime rangeStart,
            LocalDateTime rangeEnd
    ) {
        List<BusyWindow> windows = new ArrayList<>();

        for (ScheduleOccurrence occurrence : occurrences) {
            if (occurrence.getStartDateTime() == null || occurrence.getEndDateTime() == null) {
                continue;
            }

            LocalDateTime start = max(occurrence.getStartDateTime(), rangeStart);
            LocalDateTime end = min(occurrence.getEndDateTime(), rangeEnd);

            if (!start.isBefore(end)) {
                continue;
            }

            windows.add(new BusyWindow(start, end));
        }

        windows.sort(Comparator.comparing(BusyWindow::startDateTime));

        List<BusyWindow> merged = new ArrayList<>();

        for (BusyWindow current : windows) {
            if (merged.isEmpty()) {
                merged.add(current);
                continue;
            }

            BusyWindow last = merged.get(merged.size() - 1);

            if (!current.startDateTime().isAfter(last.endDateTime())) {
                merged.set(
                        merged.size() - 1,
                        new BusyWindow(
                                last.startDateTime(),
                                max(last.endDateTime(), current.endDateTime())
                        )
                );
            } else {
                merged.add(current);
            }
        }

        return merged;
    }

    private List<AvailabilityWindow> calculateFreeWindows(
            LocalDateTime rangeStart,
            LocalDateTime rangeEnd,
            List<BusyWindow> busyWindows,
            long minimumMinutes
    ) {
        List<AvailabilityWindow> freeWindows = new ArrayList<>();

        LocalDateTime cursor = rangeStart;

        for (BusyWindow busy : busyWindows) {
            if (cursor.isBefore(busy.startDateTime())) {
                AvailabilityWindow free = new AvailabilityWindow(
                        cursor,
                        busy.startDateTime()
                );

                if (free.canFitMinutes(minimumMinutes)) {
                    freeWindows.add(free);
                }
            }

            if (busy.endDateTime().isAfter(cursor)) {
                cursor = busy.endDateTime();
            }
        }

        if (cursor.isBefore(rangeEnd)) {
            AvailabilityWindow free = new AvailabilityWindow(cursor, rangeEnd);

            if (free.canFitMinutes(minimumMinutes)) {
                freeWindows.add(free);
            }
        }

        return freeWindows;
    }

    private LocalDate resolveUserDate(UUID userId, LocalDate date) {
        if (date != null) {
            return date;
        }

        return Instant.now()
                .atZone(userTimeService.getUserZoneId(userId))
                .toLocalDate();
    }

    private LocalDateTime max(LocalDateTime left, LocalDateTime right) {
        if (left.isAfter(right)) {
            return left;
        }

        return right;
    }

    private LocalDateTime min(LocalDateTime left, LocalDateTime right) {
        if (left.isBefore(right)) {
            return left;
        }

        return right;
    }

    private void validateUserId(UUID userId) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }
    }

    private void validateRange(
            LocalDateTime startDateTime,
            LocalDateTime endDateTime
    ) {
        if (startDateTime == null || endDateTime == null) {
            throw new IllegalArgumentException("startDateTime and endDateTime are required");
        }

        if (!startDateTime.isBefore(endDateTime)) {
            throw new IllegalArgumentException("startDateTime must be before endDateTime");
        }
    }

    private record BusyWindow(
            LocalDateTime startDateTime,
            LocalDateTime endDateTime
    ) {
    }

    public record AvailabilityCheckResult(
            UUID userId,
            LocalDateTime startDateTime,
            LocalDateTime endDateTime,
            boolean available,
            List<ScheduleOccurrence> conflicts
    ) {
    }
}