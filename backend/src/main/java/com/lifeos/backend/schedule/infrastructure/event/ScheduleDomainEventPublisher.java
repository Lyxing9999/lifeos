package com.lifeos.backend.schedule.infrastructure.event;

import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.schedule.domain.entity.ScheduleOccurrence;
import com.lifeos.backend.schedule.domain.event.ScheduleOccurrenceActivatedEvent;
import com.lifeos.backend.schedule.domain.event.ScheduleOccurrenceCancelledEvent;
import com.lifeos.backend.schedule.domain.event.ScheduleOccurrenceExpiredEvent;
import com.lifeos.backend.schedule.domain.event.ScheduleOccurrencePlannedEvent;
import com.lifeos.backend.schedule.domain.event.ScheduleOccurrenceRescheduledEvent;
import com.lifeos.backend.schedule.domain.event.ScheduleOccurrenceSkippedEvent;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

/**
 * Publishes Schedule domain events.
 *
 * Important boundary rule:
 * - Schedule does NOT call Timeline directly.
 * - Schedule publishes events.
 * - Timeline listens and writes TimelineEntry snapshots.
 */
@Component
@RequiredArgsConstructor
public class ScheduleDomainEventPublisher {

    private final ApplicationEventPublisher eventPublisher;
    private final UserTimeService userTimeService;

    public void publishPlanned(ScheduleOccurrence occurrence) {
        requireSavedOccurrence(occurrence);

        eventPublisher.publishEvent(
                new ScheduleOccurrencePlannedEvent(
                        occurrence.getUserId(),
                        occurrence.getId(),
                        occurrence.getTemplateId(),

                        occurrence.getTitleSnapshot(),
                        categorySnapshot(occurrence),
                        statusSnapshot(occurrence),

                        occurrence.getOccurrenceDate(),
                        occurrence.getScheduledDate(),

                        occurrence.getStartDateTime(),
                        occurrence.getEndDateTime(),

                        timezone(occurrence.getUserId())
                )
        );
    }

    public void publishPlannedAll(List<ScheduleOccurrence> occurrences) {
        if (occurrences == null || occurrences.isEmpty()) {
            return;
        }

        occurrences.forEach(this::publishPlanned);
    }

    public void publishActivated(ScheduleOccurrence occurrence) {
        requireSavedOccurrence(occurrence);

        eventPublisher.publishEvent(
                new ScheduleOccurrenceActivatedEvent(
                        occurrence.getUserId(),
                        occurrence.getId(),
                        occurrence.getTemplateId(),

                        occurrence.getTitleSnapshot(),
                        categorySnapshot(occurrence),
                        statusSnapshot(occurrence),

                        occurrence.getOccurrenceDate(),
                        occurrence.getScheduledDate(),

                        occurrence.getStartDateTime(),
                        occurrence.getEndDateTime(),

                        safeInstant(occurrence.getActivatedAt()),
                        timezone(occurrence.getUserId())
                )
        );
    }

    public void publishExpired(ScheduleOccurrence occurrence) {
        requireSavedOccurrence(occurrence);

        eventPublisher.publishEvent(
                new ScheduleOccurrenceExpiredEvent(
                        occurrence.getUserId(),
                        occurrence.getId(),
                        occurrence.getTemplateId(),

                        occurrence.getTitleSnapshot(),
                        categorySnapshot(occurrence),
                        statusSnapshot(occurrence),

                        occurrence.getOccurrenceDate(),
                        occurrence.getScheduledDate(),

                        occurrence.getStartDateTime(),
                        occurrence.getEndDateTime(),

                        safeInstant(occurrence.getExpiredAt()),
                        timezone(occurrence.getUserId())
                )
        );
    }

    public void publishCancelled(
            ScheduleOccurrence occurrence,
            String reason
    ) {
        requireSavedOccurrence(occurrence);

        eventPublisher.publishEvent(
                new ScheduleOccurrenceCancelledEvent(
                        occurrence.getUserId(),
                        occurrence.getId(),
                        occurrence.getTemplateId(),

                        occurrence.getTitleSnapshot(),
                        categorySnapshot(occurrence),
                        statusSnapshot(occurrence),

                        occurrence.getOccurrenceDate(),
                        occurrence.getScheduledDate(),

                        occurrence.getStartDateTime(),
                        occurrence.getEndDateTime(),

                        safeInstant(occurrence.getCancelledAt()),
                        normalize(reason),
                        timezone(occurrence.getUserId())
                )
        );
    }

    public void publishSkipped(
            ScheduleOccurrence occurrence,
            String reason
    ) {
        requireSavedOccurrence(occurrence);

        eventPublisher.publishEvent(
                new ScheduleOccurrenceSkippedEvent(
                        occurrence.getUserId(),
                        occurrence.getId(),
                        occurrence.getTemplateId(),

                        occurrence.getTitleSnapshot(),
                        categorySnapshot(occurrence),
                        statusSnapshot(occurrence),

                        occurrence.getOccurrenceDate(),
                        occurrence.getScheduledDate(),

                        occurrence.getStartDateTime(),
                        occurrence.getEndDateTime(),

                        safeInstant(occurrence.getSkippedAt()),
                        normalize(reason),
                        timezone(occurrence.getUserId())
                )
        );
    }

    public void publishRescheduled(
            ScheduleOccurrence source,
            ScheduleOccurrence target,
            String reason
    ) {
        requireSavedOccurrence(source);

        eventPublisher.publishEvent(
                new ScheduleOccurrenceRescheduledEvent(
                        source.getUserId(),

                        source.getId(),
                        target == null ? null : target.getId(),
                        source.getTemplateId(),

                        source.getTitleSnapshot(),
                        categorySnapshot(source),
                        statusSnapshot(source),

                        source.getOccurrenceDate(),

                        source.getStartDateTime(),
                        source.getEndDateTime(),

                        target == null ? null : target.getStartDateTime(),
                        target == null ? null : target.getEndDateTime(),

                        safeInstant(source.getRescheduledAt()),
                        normalize(reason),
                        timezone(source.getUserId())
                )
        );
    }

    private void requireSavedOccurrence(ScheduleOccurrence occurrence) {
        if (occurrence == null) {
            throw new IllegalArgumentException("ScheduleOccurrence is required");
        }

        if (occurrence.getUserId() == null) {
            throw new IllegalArgumentException("ScheduleOccurrence userId is required");
        }

        if (occurrence.getId() == null) {
            throw new IllegalArgumentException("ScheduleOccurrence id is required before publishing event");
        }

        if (occurrence.getTitleSnapshot() == null || occurrence.getTitleSnapshot().isBlank()) {
            throw new IllegalArgumentException("ScheduleOccurrence titleSnapshot is required before publishing event");
        }
    }

    private String categorySnapshot(ScheduleOccurrence occurrence) {
        if (occurrence.getTypeSnapshot() == null) {
            return null;
        }

        return occurrence.getTypeSnapshot().name();
    }

    private String statusSnapshot(ScheduleOccurrence occurrence) {
        if (occurrence.getStatus() == null) {
            return null;
        }

        return occurrence.getStatus().name();
    }

    private Instant safeInstant(Instant instant) {
        return instant == null ? Instant.now() : instant;
    }

    private String timezone(UUID userId) {
        return userTimeService.getUserZoneId(userId).getId();
    }

    private String normalize(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }

        return value.trim();
    }
}