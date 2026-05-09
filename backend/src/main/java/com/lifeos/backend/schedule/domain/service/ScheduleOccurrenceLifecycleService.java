package com.lifeos.backend.schedule.domain.service;

import com.lifeos.backend.schedule.domain.entity.ScheduleOccurrence;
import com.lifeos.backend.schedule.domain.enums.ScheduleOccurrenceStatus;
import org.springframework.stereotype.Component;

import java.time.Instant;

/**
 * Lightweight lifecycle service for schedule occurrence.
 *
 * Schedule does not need a heavy state machine yet.
 * This service is enough for:
 * - activate
 * - expire
 * - cancel
 * - skip
 * - reschedule mark
 */
@Component
public class ScheduleOccurrenceLifecycleService {

    public void activate(ScheduleOccurrence occurrence, Instant now) {
        requireOccurrence(occurrence);

        if (!occurrence.getStatus().canActivate()) {
            throw new IllegalStateException(
                    "Cannot activate schedule occurrence from status " + occurrence.getStatus()
            );
        }

        occurrence.activate(safeNow(now));
    }

    public void expire(ScheduleOccurrence occurrence, Instant now) {
        requireOccurrence(occurrence);

        if (!occurrence.getStatus().canExpire()) {
            throw new IllegalStateException(
                    "Cannot expire schedule occurrence from status " + occurrence.getStatus()
            );
        }

        occurrence.expire(safeNow(now));
    }

    public void cancel(ScheduleOccurrence occurrence, Instant now) {
        requireOccurrence(occurrence);

        if (!occurrence.getStatus().canCancel()) {
            throw new IllegalStateException(
                    "Cannot cancel schedule occurrence from status " + occurrence.getStatus()
            );
        }

        occurrence.cancel(safeNow(now));
    }

    public void skip(ScheduleOccurrence occurrence, Instant now) {
        requireOccurrence(occurrence);

        if (!occurrence.getStatus().canSkip()) {
            throw new IllegalStateException(
                    "Cannot skip schedule occurrence from status " + occurrence.getStatus()
            );
        }

        occurrence.skip(safeNow(now));
    }

    public void markRescheduled(ScheduleOccurrence occurrence, Instant now) {
        requireOccurrence(occurrence);

        if (!occurrence.getStatus().canReschedule()) {
            throw new IllegalStateException(
                    "Cannot reschedule schedule occurrence from status " + occurrence.getStatus()
            );
        }

        occurrence.markRescheduled(safeNow(now));
    }

    public void restoreToPlanned(ScheduleOccurrence occurrence) {
        requireOccurrence(occurrence);

        if (occurrence.getStatus() == ScheduleOccurrenceStatus.EXPIRED) {
            throw new IllegalStateException("Expired occurrence should not be restored to PLANNED");
        }

        occurrence.setStatus(ScheduleOccurrenceStatus.PLANNED);
        occurrence.setCancelledAt(null);
        occurrence.setSkippedAt(null);
        occurrence.setRescheduledAt(null);
    }

    private void requireOccurrence(ScheduleOccurrence occurrence) {
        if (occurrence == null) {
            throw new IllegalArgumentException("ScheduleOccurrence is required");
        }

        if (occurrence.getStatus() == null) {
            throw new IllegalArgumentException("ScheduleOccurrence status is required");
        }
    }

    private Instant safeNow(Instant now) {
        return now == null ? Instant.now() : now;
    }
}