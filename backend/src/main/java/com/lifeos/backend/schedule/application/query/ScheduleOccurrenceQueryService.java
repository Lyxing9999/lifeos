package com.lifeos.backend.schedule.application.query;

import com.lifeos.backend.common.exception.NotFoundException;
import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.schedule.domain.entity.ScheduleOccurrence;
import com.lifeos.backend.schedule.domain.enums.ScheduleOccurrenceStatus;
import com.lifeos.backend.schedule.domain.repository.ScheduleOccurrenceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

/**
 * Read-side service for ScheduleOccurrence.
 *
 * ScheduleOccurrence = real planned time block.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ScheduleOccurrenceQueryService {

    private final ScheduleOccurrenceRepository occurrenceRepository;
    private final UserTimeService userTimeService;

    public ScheduleOccurrence getByIdForUser(UUID userId, UUID occurrenceId) {
        validateUserId(userId);
        validateOccurrenceId(occurrenceId);

        return occurrenceRepository.findByIdForUser(userId, occurrenceId)
                .orElseThrow(() -> new NotFoundException("Schedule occurrence not found"));
    }

    public List<ScheduleOccurrence> getOccurrencesForDay(UUID userId, LocalDate date) {
        validateUserId(userId);

        LocalDate targetDate = resolveUserDate(userId, date);

        return occurrenceRepository.findByUserIdAndScheduledDate(userId, targetDate)
                .stream()
                .sorted(occurrenceComparator())
                .toList();
    }

    public List<ScheduleOccurrence> getVisibleOccurrencesForDay(UUID userId, LocalDate date) {
        validateUserId(userId);

        return getOccurrencesForDay(userId, date)
                .stream()
                .filter(this::isVisibleOnScheduleSurface)
                .toList();
    }

    public List<ScheduleOccurrence> getTimelineOccurrencesForDay(UUID userId, LocalDate date) {
        validateUserId(userId);

        LocalDate targetDate = resolveUserDate(userId, date);

        return occurrenceRepository.findByUserIdAndScheduledDate(userId, targetDate)
                .stream()
                .filter(this::isTimelineRelevant)
                .sorted(occurrenceComparator())
                .toList();
    }

    public List<ScheduleOccurrence> getOccurrencesByDateRange(
            UUID userId,
            LocalDate startDate,
            LocalDate endDate
    ) {
        validateUserId(userId);
        validateDateRange(startDate, endDate);

        return occurrenceRepository.findByUserIdAndScheduledDateBetween(
                        userId,
                        startDate,
                        endDate
                )
                .stream()
                .sorted(occurrenceComparator())
                .toList();
    }

    public List<ScheduleOccurrence> getVisibleOccurrencesByDateRange(
            UUID userId,
            LocalDate startDate,
            LocalDate endDate
    ) {
        return getOccurrencesByDateRange(userId, startDate, endDate)
                .stream()
                .filter(this::isVisibleOnScheduleSurface)
                .toList();
    }

    public List<ScheduleOccurrence> getPlanned(UUID userId) {
        return getByStatus(userId, ScheduleOccurrenceStatus.PLANNED);
    }

    public List<ScheduleOccurrence> getActive(UUID userId) {
        return getByStatus(userId, ScheduleOccurrenceStatus.ACTIVE);
    }

    public List<ScheduleOccurrence> getExpired(UUID userId) {
        return getByStatus(userId, ScheduleOccurrenceStatus.EXPIRED);
    }

    public List<ScheduleOccurrence> getCancelled(UUID userId) {
        return getByStatus(userId, ScheduleOccurrenceStatus.CANCELLED);
    }

    public List<ScheduleOccurrence> getSkipped(UUID userId) {
        return getByStatus(userId, ScheduleOccurrenceStatus.SKIPPED);
    }

    public List<ScheduleOccurrence> getRescheduled(UUID userId) {
        return getByStatus(userId, ScheduleOccurrenceStatus.RESCHEDULED);
    }

    public List<ScheduleOccurrence> getByStatus(
            UUID userId,
            ScheduleOccurrenceStatus status
    ) {
        validateUserId(userId);

        if (status == null) {
            throw new IllegalArgumentException("status is required");
        }

        return occurrenceRepository.findByUserIdAndStatus(userId, status)
                .stream()
                .sorted(occurrenceComparator())
                .toList();
    }

    /**
     * Used by schedule lifecycle workers.
     *
     * Finds PLANNED/ACTIVE occurrences whose end time already passed.
     */
    public List<ScheduleOccurrence> getOpenOccurrencesBeforeNow(UUID userId) {
        validateUserId(userId);

        return occurrenceRepository.findOpenOccurrencesBefore(
                        userId,
                        resolveUserNowLocal(userId),
                        openStatuses()
                )
                .stream()
                .sorted(occurrenceComparator())
                .toList();
    }

    /**
     * Used by schedule lifecycle workers.
     *
     * Finds PLANNED occurrences that should become ACTIVE now.
     */
    public List<ScheduleOccurrence> getOccurrencesActiveNow(UUID userId) {
        validateUserId(userId);

        return occurrenceRepository.findOccurrencesActiveAt(
                        userId,
                        resolveUserNowLocal(userId),
                        List.of(ScheduleOccurrenceStatus.PLANNED)
                )
                .stream()
                .sorted(occurrenceComparator())
                .toList();
    }

    public List<ScheduleOccurrence> getOverlapping(
            UUID userId,
            LocalDateTime startDateTime,
            LocalDateTime endDateTime
    ) {
        validateUserId(userId);
        validateTimeWindow(startDateTime, endDateTime);

        return occurrenceRepository.findOverlapping(
                        userId,
                        startDateTime,
                        endDateTime
                )
                .stream()
                .sorted(occurrenceComparator())
                .toList();
    }

    public List<ScheduleOccurrence> getRescheduledTargets(UUID sourceOccurrenceId) {
        if (sourceOccurrenceId == null) {
            throw new IllegalArgumentException("sourceOccurrenceId is required");
        }

        return occurrenceRepository.findByRescheduledFromOccurrenceId(sourceOccurrenceId)
                .stream()
                .sorted(occurrenceComparator())
                .toList();
    }

    public List<ScheduleOccurrence> getRescheduledSources(UUID targetOccurrenceId) {
        if (targetOccurrenceId == null) {
            throw new IllegalArgumentException("targetOccurrenceId is required");
        }

        return occurrenceRepository.findByRescheduledToOccurrenceId(targetOccurrenceId)
                .stream()
                .sorted(occurrenceComparator())
                .toList();
    }

    public ScheduleDayView getScheduleDayView(UUID userId, LocalDate date) {
        validateUserId(userId);

        LocalDate targetDate = resolveUserDate(userId, date);

        List<ScheduleOccurrence> all = getOccurrencesForDay(userId, targetDate);

        List<ScheduleOccurrence> visible = all.stream()
                .filter(this::isVisibleOnScheduleSurface)
                .toList();

        List<ScheduleOccurrence> planned = all.stream()
                .filter(occurrence -> occurrence.getStatus() == ScheduleOccurrenceStatus.PLANNED)
                .toList();

        List<ScheduleOccurrence> active = all.stream()
                .filter(occurrence -> occurrence.getStatus() == ScheduleOccurrenceStatus.ACTIVE)
                .toList();

        List<ScheduleOccurrence> expired = all.stream()
                .filter(occurrence -> occurrence.getStatus() == ScheduleOccurrenceStatus.EXPIRED)
                .toList();

        List<ScheduleOccurrence> cancelled = all.stream()
                .filter(occurrence -> occurrence.getStatus() == ScheduleOccurrenceStatus.CANCELLED)
                .toList();

        List<ScheduleOccurrence> skipped = all.stream()
                .filter(occurrence -> occurrence.getStatus() == ScheduleOccurrenceStatus.SKIPPED)
                .toList();

        List<ScheduleOccurrence> rescheduled = all.stream()
                .filter(occurrence -> occurrence.getStatus() == ScheduleOccurrenceStatus.RESCHEDULED)
                .toList();

        return new ScheduleDayView(
                userId,
                targetDate,
                all,
                visible,
                planned,
                active,
                expired,
                cancelled,
                skipped,
                rescheduled,
                new ScheduleDayCounts(
                        all.size(),
                        visible.size(),
                        planned.size(),
                        active.size(),
                        expired.size(),
                        cancelled.size(),
                        skipped.size(),
                        rescheduled.size()
                )
        );
    }

    private boolean isVisibleOnScheduleSurface(ScheduleOccurrence occurrence) {
        if (occurrence == null || occurrence.getStatus() == null) {
            return false;
        }

        return occurrence.getStatus() == ScheduleOccurrenceStatus.PLANNED
                || occurrence.getStatus() == ScheduleOccurrenceStatus.ACTIVE
                || occurrence.getStatus() == ScheduleOccurrenceStatus.EXPIRED;
    }

    private boolean isTimelineRelevant(ScheduleOccurrence occurrence) {
        if (occurrence == null || occurrence.getStatus() == null) {
            return false;
        }

        /**
         * Timeline can show cancelled/skipped/rescheduled as history,
         * but Today/Schedule surfaces may hide them.
         */
        return true;
    }

    private List<ScheduleOccurrenceStatus> openStatuses() {
        return List.of(
                ScheduleOccurrenceStatus.PLANNED,
                ScheduleOccurrenceStatus.ACTIVE
        );
    }

    private LocalDate resolveUserDate(UUID userId, LocalDate date) {
        if (date != null) {
            return date;
        }

        return Instant.now()
                .atZone(userTimeService.getUserZoneId(userId))
                .toLocalDate();
    }

    private LocalDateTime resolveUserNowLocal(UUID userId) {
        return Instant.now()
                .atZone(userTimeService.getUserZoneId(userId))
                .toLocalDateTime();
    }

    private Comparator<ScheduleOccurrence> occurrenceComparator() {
        return Comparator
                .comparing(ScheduleOccurrence::getStartDateTime, Comparator.nullsLast(Comparator.naturalOrder()))
                .thenComparing(ScheduleOccurrence::getEndDateTime, Comparator.nullsLast(Comparator.naturalOrder()))
                .thenComparing(ScheduleOccurrence::getTitleSnapshot, Comparator.nullsLast(String::compareToIgnoreCase));
    }

    private void validateUserId(UUID userId) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }
    }

    private void validateOccurrenceId(UUID occurrenceId) {
        if (occurrenceId == null) {
            throw new IllegalArgumentException("occurrenceId is required");
        }
    }

    private void validateDateRange(LocalDate startDate, LocalDate endDate) {
        if (startDate == null) {
            throw new IllegalArgumentException("startDate is required");
        }

        if (endDate == null) {
            throw new IllegalArgumentException("endDate is required");
        }

        if (endDate.isBefore(startDate)) {
            throw new IllegalArgumentException("endDate must be on or after startDate");
        }
    }

    private void validateTimeWindow(
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

    public record ScheduleDayView(
            UUID userId,
            LocalDate date,
            List<ScheduleOccurrence> all,
            List<ScheduleOccurrence> visible,
            List<ScheduleOccurrence> planned,
            List<ScheduleOccurrence> active,
            List<ScheduleOccurrence> expired,
            List<ScheduleOccurrence> cancelled,
            List<ScheduleOccurrence> skipped,
            List<ScheduleOccurrence> rescheduled,
            ScheduleDayCounts counts
    ) {
    }

    public record ScheduleDayCounts(
            int total,
            int visible,
            int planned,
            int active,
            int expired,
            int cancelled,
            int skipped,
            int rescheduled
    ) {
    }
}