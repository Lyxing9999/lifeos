package com.lifeos.backend.timeline.application;

import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.schedule.application.query.ScheduleOccurrenceQueryService;
import com.lifeos.backend.schedule.domain.entity.ScheduleOccurrence;
import com.lifeos.backend.schedule.domain.enums.ScheduleOccurrenceStatus;
import com.lifeos.backend.task.application.query.TaskInstanceQueryService;
import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.timeline.application.TimelineIngestionService.IngestTimelineEntryCommand;
import com.lifeos.backend.timeline.application.TimelineIngestionService.TimelineIngestionResult;
import com.lifeos.backend.timeline.domain.enums.TimelineAnchorType;
import com.lifeos.backend.timeline.domain.enums.TimelineEntryType;
import com.lifeos.backend.timeline.domain.enums.TimelineSourceType;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * Maintenance/backfill service.
 *
 * Purpose:
 * - migrate Phase 1 dynamic Timeline into TimelineEntry ledger
 * - rebuild missing TimelineEntry rows if listeners were disabled
 * - backfill old Task/Schedule facts
 *
 * Important:
 * This is NOT the normal Timeline read path.
 * Normal Timeline reads from TimelineEntryRepository only.
 */
@Service
@RequiredArgsConstructor
public class TimelineRebuildService {

    private final TimelineIngestionService timelineIngestionService;
    private final UserTimeService userTimeService;

    private final TaskInstanceQueryService taskInstanceQueryService;
    private final ScheduleOccurrenceQueryService scheduleOccurrenceQueryService;

    @Transactional
    public TimelineRebuildResult rebuild(
            UUID userId,
            LocalDate startDate,
            LocalDate endDate,
            boolean includeTasks,
            boolean includeSchedule
    ) {
        validate(userId, startDate, endDate);

        ZoneId zoneId = userTimeService.getUserZoneId(userId);

        int scannedDays = 0;
        int scannedTasks = 0;
        int scannedScheduleOccurrences = 0;
        int createdEntries = 0;
        int existingEntries = 0;
        int failedEntries = 0;

        List<String> errors = new ArrayList<>();

        for (LocalDate date = startDate; !date.isAfter(endDate); date = date.plusDays(1)) {
            scannedDays++;

            if (includeTasks) {
                BackfillCounter taskCounter = rebuildTasksForDay(userId, date, zoneId, errors);

                scannedTasks += taskCounter.scanned();
                createdEntries += taskCounter.created();
                existingEntries += taskCounter.existing();
                failedEntries += taskCounter.failed();
            }

            if (includeSchedule) {
                BackfillCounter scheduleCounter = rebuildScheduleForDay(userId, date, zoneId, errors);

                scannedScheduleOccurrences += scheduleCounter.scanned();
                createdEntries += scheduleCounter.created();
                existingEntries += scheduleCounter.existing();
                failedEntries += scheduleCounter.failed();
            }
        }

        return new TimelineRebuildResult(
                userId,
                startDate,
                endDate,
                scannedDays,
                scannedTasks,
                scannedScheduleOccurrences,
                createdEntries,
                existingEntries,
                failedEntries,
                errors
        );
    }

    private BackfillCounter rebuildTasksForDay(
            UUID userId,
            LocalDate date,
            ZoneId zoneId,
            List<String> errors
    ) {
        int scanned = 0;
        int created = 0;
        int existing = 0;
        int failed = 0;

        /**
         * Use both:
         * - completion history
         * - day/range visible facts if your query service supports them
         *
         * This keeps backfill simple and focused on finished/lifecycle facts first.
         */
        List<TaskInstance> completed = safeList(
                taskInstanceQueryService.getCompletionHistoryForDay(userId, date)
        );

        List<TaskInstance> missed = safeList(
                taskInstanceQueryService.getMissed(userId)
        ).stream()
                .filter(task -> sameLocalDate(task.getMissedAt(), date, zoneId))
                .toList();

        List<TaskInstance> skipped = safeList(
                taskInstanceQueryService.getSkipped(userId)
        ).stream()
                .filter(task -> sameLocalDate(task.getSkippedAt(), date, zoneId))
                .toList();

        List<TaskInstance> rolledOver = safeList(
                taskInstanceQueryService.getByScheduledDate(userId, date)
        ).stream()
                .filter(task -> task.getStatus() == TaskInstanceStatus.ROLLED_OVER)
                .toList();

        List<TaskInstance> all = new ArrayList<>();
        all.addAll(completed);
        all.addAll(missed);
        all.addAll(skipped);
        all.addAll(rolledOver);

        for (TaskInstance task : all) {
            scanned++;

            try {
                IngestTimelineEntryCommand command = toTaskBackfillCommand(task, zoneId);

                if (command == null) {
                    continue;
                }

                TimelineIngestionResult result = timelineIngestionService.ingest(command);

                if (result.created()) {
                    created++;
                } else {
                    existing++;
                }

            } catch (Exception ex) {
                failed++;
                errors.add("Task backfill failed taskId="
                        + safeId(task)
                        + " date="
                        + date
                        + " error="
                        + ex.getMessage());
            }
        }

        return new BackfillCounter(scanned, created, existing, failed);
    }

    private BackfillCounter rebuildScheduleForDay(
            UUID userId,
            LocalDate date,
            ZoneId zoneId,
            List<String> errors
    ) {
        int scanned = 0;
        int created = 0;
        int existing = 0;
        int failed = 0;

        List<ScheduleOccurrence> occurrences = safeList(
                scheduleOccurrenceQueryService.getTimelineOccurrencesForDay(userId, date)
        );

        for (ScheduleOccurrence occurrence : occurrences) {
            scanned++;

            try {
                List<IngestTimelineEntryCommand> commands =
                        toScheduleBackfillCommands(occurrence, zoneId);

                for (IngestTimelineEntryCommand command : commands) {
                    TimelineIngestionResult result = timelineIngestionService.ingest(command);

                    if (result.created()) {
                        created++;
                    } else {
                        existing++;
                    }
                }

            } catch (Exception ex) {
                failed++;
                errors.add("Schedule backfill failed occurrenceId="
                        + safeId(occurrence)
                        + " date="
                        + date
                        + " error="
                        + ex.getMessage());
            }
        }

        return new BackfillCounter(scanned, created, existing, failed);
    }

    private IngestTimelineEntryCommand toTaskBackfillCommand(
            TaskInstance task,
            ZoneId zoneId
    ) {
        if (task == null || task.getStatus() == null) {
            return null;
        }

        TimelineEntryType entryType;
        Instant startAt;
        String badge;
        String subtitle;

        if (task.getStatus() == TaskInstanceStatus.COMPLETED) {
            entryType = TimelineEntryType.TASK_COMPLETED;
            startAt = safeInstant(task.getCompletedAt());
            badge = "Done";
            subtitle = "Completed task";

        } else if (task.getStatus() == TaskInstanceStatus.MISSED) {
            entryType = TimelineEntryType.TASK_MISSED;
            startAt = safeInstant(task.getMissedAt());
            badge = "Missed";
            subtitle = "Missed task";

        } else if (task.getStatus() == TaskInstanceStatus.SKIPPED) {
            entryType = TimelineEntryType.TASK_SKIPPED;
            startAt = safeInstant(task.getSkippedAt());
            badge = "Skipped";
            subtitle = "Skipped task";

        } else if (task.getStatus() == TaskInstanceStatus.ROLLED_OVER) {
            entryType = TimelineEntryType.TASK_ROLLED_OVER;
            startAt = safeInstant(task.getRolledOverAt());
            badge = "Rolled over";
            subtitle = "Rolled over task";

        } else {
            return null;
        }

        return new IngestTimelineEntryCommand(
                task.getUserId(),

                entryType,
                TimelineSourceType.TASK,
                TimelineAnchorType.POINT,

                task.getId(),
                task.getTemplateId(),
                task.getId(),

                startAt,
                null,
                zoneId.getId(),

                safeTitle(task.getTitleSnapshot()),
                subtitle,
                task.getCategorySnapshot(),
                task.getStatus().name(),
                badge,
                taskMetadata(task),

                "BACKFILL:" + entryType + ":" + task.getId(),
                10
        );
    }

    private List<IngestTimelineEntryCommand> toScheduleBackfillCommands(
            ScheduleOccurrence occurrence,
            ZoneId zoneId
    ) {
        if (occurrence == null || occurrence.getStatus() == null) {
            return List.of();
        }

        List<IngestTimelineEntryCommand> commands = new ArrayList<>();

        /**
         * The planned schedule block is a SPAN.
         * This is the main thing Timeline should show chronologically.
         */
        if (occurrence.getStartDateTime() != null && occurrence.getEndDateTime() != null) {
            commands.add(
                    new IngestTimelineEntryCommand(
                            occurrence.getUserId(),

                            TimelineEntryType.SCHEDULE_PLANNED,
                            TimelineSourceType.SCHEDULE,
                            TimelineAnchorType.SPAN,

                            occurrence.getId(),
                            occurrence.getTemplateId(),
                            occurrence.getId(),

                            occurrence.getStartDateTime().atZone(zoneId).toInstant(),
                            occurrence.getEndDateTime().atZone(zoneId).toInstant(),
                            zoneId.getId(),

                            safeTitle(occurrence.getTitleSnapshot()),
                            occurrence.getTypeSnapshot() == null
                                    ? "Schedule"
                                    : occurrence.getTypeSnapshot().name(),
                            occurrence.getTypeSnapshot() == null
                                    ? null
                                    : occurrence.getTypeSnapshot().name(),
                            occurrence.getStatus().name(),
                            "Schedule",
                            scheduleMetadata(occurrence),

                            "BACKFILL:SCHEDULE_PLANNED:" + occurrence.getId(),
                            100
                    )
            );
        }

        /**
         * Final lifecycle facts can be point entries.
         */
        if (occurrence.getStatus() == ScheduleOccurrenceStatus.EXPIRED) {
            commands.add(
                    schedulePointCommand(
                            occurrence,
                            zoneId,
                            TimelineEntryType.SCHEDULE_EXPIRED,
                            safeInstant(occurrence.getExpiredAt()),
                            "Schedule block ended",
                            "Expired",
                            110
                    )
            );
        }

        if (occurrence.getStatus() == ScheduleOccurrenceStatus.CANCELLED) {
            commands.add(
                    schedulePointCommand(
                            occurrence,
                            zoneId,
                            TimelineEntryType.SCHEDULE_CANCELLED,
                            safeInstant(occurrence.getCancelledAt()),
                            "Cancelled schedule block",
                            "Cancelled",
                            120
                    )
            );
        }

        if (occurrence.getStatus() == ScheduleOccurrenceStatus.SKIPPED) {
            commands.add(
                    schedulePointCommand(
                            occurrence,
                            zoneId,
                            TimelineEntryType.SCHEDULE_SKIPPED,
                            safeInstant(occurrence.getSkippedAt()),
                            "Skipped schedule block",
                            "Skipped",
                            130
                    )
            );
        }

        if (occurrence.getStatus() == ScheduleOccurrenceStatus.RESCHEDULED) {
            commands.add(
                    schedulePointCommand(
                            occurrence,
                            zoneId,
                            TimelineEntryType.SCHEDULE_RESCHEDULED,
                            safeInstant(occurrence.getRescheduledAt()),
                            "Rescheduled schedule block",
                            "Rescheduled",
                            140
                    )
            );
        }

        return commands;
    }

    private IngestTimelineEntryCommand schedulePointCommand(
            ScheduleOccurrence occurrence,
            ZoneId zoneId,
            TimelineEntryType entryType,
            Instant startAt,
            String subtitle,
            String badge,
            Integer sortOrder
    ) {
        return new IngestTimelineEntryCommand(
                occurrence.getUserId(),

                entryType,
                TimelineSourceType.SCHEDULE,
                TimelineAnchorType.POINT,

                occurrence.getId(),
                occurrence.getTemplateId(),
                occurrence.getId(),

                startAt,
                null,
                zoneId.getId(),

                safeTitle(occurrence.getTitleSnapshot()),
                subtitle,
                occurrence.getTypeSnapshot() == null
                        ? null
                        : occurrence.getTypeSnapshot().name(),
                occurrence.getStatus().name(),
                badge,
                scheduleMetadata(occurrence),

                "BACKFILL:" + entryType + ":" + occurrence.getId(),
                sortOrder
        );
    }

    private boolean sameLocalDate(
            Instant instant,
            LocalDate date,
            ZoneId zoneId
    ) {
        if (instant == null || date == null || zoneId == null) {
            return false;
        }

        return instant.atZone(zoneId).toLocalDate().equals(date);
    }

    private Instant safeInstant(Instant instant) {
        return instant == null ? Instant.now() : instant;
    }

    private String safeTitle(String title) {
        if (title == null || title.isBlank()) {
            return "Untitled";
        }

        return title.trim();
    }

    private String taskMetadata(TaskInstance task) {
        return """
        {
          "priority": "%s",
          "category": "%s",
          "scheduledDate": "%s",
          "dueDateTime": "%s"
        }
        """.formatted(
                task.getPrioritySnapshot() == null ? "" : task.getPrioritySnapshot().name(),
                safe(task.getCategorySnapshot()),
                safe(task.getScheduledDate()),
                safe(task.getDueDateTime())
        );
    }

    private String scheduleMetadata(ScheduleOccurrence occurrence) {
        return """
        {
          "occurrenceDate": "%s",
          "scheduledDate": "%s",
          "sourceType": "%s",
          "rescheduledFromOccurrenceId": "%s",
          "rescheduledToOccurrenceId": "%s"
        }
        """.formatted(
                safe(occurrence.getOccurrenceDate()),
                safe(occurrence.getScheduledDate()),
                occurrence.getSourceType() == null ? "" : occurrence.getSourceType().name(),
                safe(occurrence.getRescheduledFromOccurrenceId()),
                safe(occurrence.getRescheduledToOccurrenceId())
        );
    }

    private String safe(Object value) {
        return value == null ? "" : value.toString().replace("\"", "\\\"");
    }

    private String safeId(Object entity) {
        if (entity instanceof TaskInstance task) {
            return safe(task.getId());
        }

        if (entity instanceof ScheduleOccurrence occurrence) {
            return safe(occurrence.getId());
        }

        return "";
    }

    private <T> List<T> safeList(List<T> list) {
        return list == null ? List.of() : list;
    }

    private void validate(
            UUID userId,
            LocalDate startDate,
            LocalDate endDate
    ) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }

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

    private record BackfillCounter(
            int scanned,
            int created,
            int existing,
            int failed
    ) {
    }

    public record TimelineRebuildResult(
            UUID userId,
            LocalDate startDate,
            LocalDate endDate,

            int scannedDays,
            int scannedTasks,
            int scannedScheduleOccurrences,

            int createdEntries,
            int existingEntries,
            int failedEntries,

            List<String> errors
    ) {
    }
}