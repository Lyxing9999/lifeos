package com.lifeos.backend.timeline.infrastructure.listener;

import com.lifeos.backend.schedule.domain.event.ScheduleOccurrenceCancelledEvent;
import com.lifeos.backend.schedule.domain.event.ScheduleOccurrenceExpiredEvent;
import com.lifeos.backend.schedule.domain.event.ScheduleOccurrencePlannedEvent;
import com.lifeos.backend.schedule.domain.event.ScheduleOccurrenceRescheduledEvent;
import com.lifeos.backend.schedule.domain.event.ScheduleOccurrenceSkippedEvent;
import com.lifeos.backend.timeline.application.TimelineIngestionService;
import com.lifeos.backend.timeline.application.TimelineIngestionService.IngestTimelineEntryCommand;
import com.lifeos.backend.timeline.domain.enums.TimelineAnchorType;
import com.lifeos.backend.timeline.domain.enums.TimelineEntryType;
import com.lifeos.backend.timeline.domain.enums.TimelineSourceType;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionalEventListener;
import org.springframework.transaction.event.TransactionPhase;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;

@Component
@RequiredArgsConstructor
public class ScheduleTimelineListener {

    private final TimelineIngestionService timelineIngestionService;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void on(ScheduleOccurrencePlannedEvent event) {
        ZoneId zoneId = resolveZone(event.timezone());

        timelineIngestionService.ingest(
                new IngestTimelineEntryCommand(
                        event.userId(),

                        TimelineEntryType.SCHEDULE_PLANNED,
                        TimelineSourceType.SCHEDULE,
                        TimelineAnchorType.SPAN,

                        event.scheduleOccurrenceId(),
                        event.scheduleTemplateId(),
                        event.scheduleOccurrenceId(),

                        toInstant(event.startDateTime(), zoneId),
                        toInstant(event.endDateTime(), zoneId),
                        zoneId.getId(),

                        event.titleSnapshot(),
                        event.categorySnapshot(),
                        event.categorySnapshot(),
                        event.statusSnapshot(),
                        "Schedule",
                        scheduleMetadata(
                                event.occurrenceDate(),
                                event.scheduledDate(),
                                null
                        ),

                        "SCHEDULE_PLANNED:" + event.scheduleOccurrenceId(),
                        100
                )
        );
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void on(ScheduleOccurrenceExpiredEvent event) {
        ZoneId zoneId = resolveZone(event.timezone());

        timelineIngestionService.ingest(
                new IngestTimelineEntryCommand(
                        event.userId(),

                        TimelineEntryType.SCHEDULE_EXPIRED,
                        TimelineSourceType.SCHEDULE,
                        TimelineAnchorType.POINT,

                        event.scheduleOccurrenceId(),
                        event.scheduleTemplateId(),
                        event.scheduleOccurrenceId(),

                        event.expiredAt() == null
                                ? toInstant(event.endDateTime(), zoneId)
                                : event.expiredAt(),
                        null,
                        zoneId.getId(),

                        event.titleSnapshot(),
                        "Schedule block ended",
                        event.categorySnapshot(),
                        event.statusSnapshot(),
                        "Expired",
                        scheduleMetadata(
                                event.occurrenceDate(),
                                event.scheduledDate(),
                                null
                        ),

                        "SCHEDULE_EXPIRED:" + event.scheduleOccurrenceId(),
                        110
                )
        );
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void on(ScheduleOccurrenceCancelledEvent event) {
        ZoneId zoneId = resolveZone(event.timezone());

        timelineIngestionService.ingest(
                new IngestTimelineEntryCommand(
                        event.userId(),

                        TimelineEntryType.SCHEDULE_CANCELLED,
                        TimelineSourceType.SCHEDULE,
                        TimelineAnchorType.POINT,

                        event.scheduleOccurrenceId(),
                        event.scheduleTemplateId(),
                        event.scheduleOccurrenceId(),

                        safeInstant(event.cancelledAt()),
                        null,
                        zoneId.getId(),

                        event.titleSnapshot(),
                        "Cancelled",
                        event.categorySnapshot(),
                        event.statusSnapshot(),
                        "Cancelled",
                        scheduleMetadata(
                                event.occurrenceDate(),
                                event.scheduledDate(),
                                event.reason()
                        ),

                        "SCHEDULE_CANCELLED:" + event.scheduleOccurrenceId(),
                        120
                )
        );
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void on(ScheduleOccurrenceSkippedEvent event) {
        ZoneId zoneId = resolveZone(event.timezone());

        timelineIngestionService.ingest(
                new IngestTimelineEntryCommand(
                        event.userId(),

                        TimelineEntryType.SCHEDULE_SKIPPED,
                        TimelineSourceType.SCHEDULE,
                        TimelineAnchorType.POINT,

                        event.scheduleOccurrenceId(),
                        event.scheduleTemplateId(),
                        event.scheduleOccurrenceId(),

                        safeInstant(event.skippedAt()),
                        null,
                        zoneId.getId(),

                        event.titleSnapshot(),
                        "Skipped",
                        event.categorySnapshot(),
                        event.statusSnapshot(),
                        "Skipped",
                        scheduleMetadata(
                                event.occurrenceDate(),
                                event.scheduledDate(),
                                event.reason()
                        ),

                        "SCHEDULE_SKIPPED:" + event.scheduleOccurrenceId(),
                        130
                )
        );
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void on(ScheduleOccurrenceRescheduledEvent event) {
        ZoneId zoneId = resolveZone(event.timezone());

        timelineIngestionService.ingest(
                new IngestTimelineEntryCommand(
                        event.userId(),

                        TimelineEntryType.SCHEDULE_RESCHEDULED,
                        TimelineSourceType.SCHEDULE,
                        TimelineAnchorType.POINT,

                        event.sourceScheduleOccurrenceId(),
                        event.scheduleTemplateId(),
                        event.sourceScheduleOccurrenceId(),

                        safeInstant(event.rescheduledAt()),
                        null,
                        zoneId.getId(),

                        event.titleSnapshot(),
                        "Rescheduled to " + event.toStartDateTime(),
                        event.categorySnapshot(),
                        event.statusSnapshot(),
                        "Rescheduled",
                        """
                        {
                          "reason": "%s",
                          "sourceScheduleOccurrenceId": "%s",
                          "targetScheduleOccurrenceId": "%s",
                          "originalOccurrenceDate": "%s",
                          "fromStartDateTime": "%s",
                          "fromEndDateTime": "%s",
                          "toStartDateTime": "%s",
                          "toEndDateTime": "%s"
                        }
                        """.formatted(
                                safe(event.reason()),
                                safe(event.sourceScheduleOccurrenceId()),
                                safe(event.targetScheduleOccurrenceId()),
                                safe(event.originalOccurrenceDate()),
                                safe(event.fromStartDateTime()),
                                safe(event.fromEndDateTime()),
                                safe(event.toStartDateTime()),
                                safe(event.toEndDateTime())
                        ),

                        "SCHEDULE_RESCHEDULED:"
                                + event.sourceScheduleOccurrenceId()
                                + ":"
                                + event.rescheduledAt(),
                        140
                )
        );
    }

    private ZoneId resolveZone(String timezone) {
        if (timezone == null || timezone.isBlank()) {
            return ZoneId.of("Asia/Phnom_Penh");
        }

        return ZoneId.of(timezone);
    }

    private Instant toInstant(LocalDateTime dateTime, ZoneId zoneId) {
        if (dateTime == null) {
            return Instant.now();
        }

        return dateTime.atZone(zoneId).toInstant();
    }

    private Instant safeInstant(Instant instant) {
        return instant == null ? Instant.now() : instant;
    }

    private String scheduleMetadata(
            Object occurrenceDate,
            Object scheduledDate,
            String reason
    ) {
        return """
        {
          "occurrenceDate": "%s",
          "scheduledDate": "%s",
          "reason": "%s"
        }
        """.formatted(
                safe(occurrenceDate),
                safe(scheduledDate),
                safe(reason)
        );
    }

    private String safe(Object value) {
        return value == null ? "" : value.toString().replace("\"", "\\\"");
    }
}