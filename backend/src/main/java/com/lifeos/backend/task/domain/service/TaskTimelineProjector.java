package com.lifeos.backend.task.domain.service;

import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.task.domain.enums.TaskPriority;
import com.lifeos.backend.task.domain.enums.TaskSourceType;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

@Component
public class TaskTimelineProjector {

    public TimelineTaskProjection project(TaskInstance instance) {
        if (instance == null) {
            return null;
        }

        return new TimelineTaskProjection(
                instance.getId(),
                instance.getUserId(),
                instance.getTemplateId(),
                instance.getTitleSnapshot(),
                instance.getStatus(),
                instance.getPrioritySnapshot(),
                instance.getSourceType(),
                resolveAnchorDate(instance),
                resolveStartDateTime(instance),
                resolveEndDateTime(instance),
                instance.getOccurrenceDate(),
                instance.getScheduledDate(),
                instance.getDueDateTime(),
                instance.getStartedAt(),
                instance.getCompletedAt(),
                instance.getAchievedDate(),
                instance.getMissedAt(),
                instance.getSkippedAt(),
                instance.getRolledOverAt(),
                instance.getLinkedScheduleBlockIdSnapshot(),
                instance.getRolledOverFromInstanceId(),
                instance.getRolledOverToInstanceId(),
                resolveLane(instance),
                resolveSortRank(instance)
        );
    }

    public List<TimelineTaskProjection> projectAll(List<TaskInstance> instances) {
        if (instances == null) {
            return List.of();
        }

        return instances.stream()
                .map(this::project)
                .filter(java.util.Objects::nonNull)
                .sorted(projectionComparator())
                .toList();
    }

    public String resolveLane(TaskInstance instance) {
        if (instance == null || instance.getStatus() == null) {
            return "UNKNOWN";
        }

        return switch (instance.getStatus()) {
            case INBOX -> "INBOX";
            case SCHEDULED -> "SCHEDULED";
            case DUE_TODAY -> "DUE_TODAY";
            case IN_PROGRESS -> "IN_PROGRESS";
            case OVERDUE -> "OVERDUE";
            case COMPLETED -> "DONE";
            case ROLLED_OVER -> "ROLLED_OVER";
            case MISSED -> "MISSED";
            case SKIPPED -> "SKIPPED";
            case PAUSED -> "PAUSED";
            case ARCHIVED -> "ARCHIVED";
            case CANCELLED -> "CANCELLED";
        };
    }

    public LocalDate resolveAnchorDate(TaskInstance instance) {
        if (instance == null) {
            return null;
        }

        if (instance.getStatus() == TaskInstanceStatus.COMPLETED
                && instance.getAchievedDate() != null) {
            return instance.getAchievedDate();
        }

        if (instance.getScheduledDate() != null) {
            return instance.getScheduledDate();
        }

        if (instance.getDueDateTime() != null) {
            return instance.getDueDateTime().toLocalDate();
        }

        if (instance.getOccurrenceDate() != null) {
            return instance.getOccurrenceDate();
        }

        return null;
    }

    public LocalDateTime resolveStartDateTime(TaskInstance instance) {
        if (instance == null) {
            return null;
        }

        if (instance.getDueDateTime() != null) {
            return instance.getDueDateTime();
        }

        return null;
    }

    public LocalDateTime resolveEndDateTime(TaskInstance instance) {
        return null;
    }

    public int resolveSortRank(TaskInstance instance) {
        if (instance == null || instance.getStatus() == null) {
            return 99;
        }

        return switch (instance.getStatus()) {
            case OVERDUE -> 0;
            case IN_PROGRESS -> 1;
            case DUE_TODAY -> 2;
            case SCHEDULED -> 3;
            case INBOX -> 4;
            case COMPLETED -> 5;
            case ROLLED_OVER -> 6;
            case MISSED -> 7;
            case SKIPPED -> 8;
            case PAUSED -> 9;
            case ARCHIVED -> 10;
            case CANCELLED -> 11;
        };
    }

    private Comparator<TimelineTaskProjection> projectionComparator() {
        return Comparator
                .comparing(TimelineTaskProjection::anchorDate, Comparator.nullsLast(Comparator.naturalOrder()))
                .thenComparing(TimelineTaskProjection::sortRank)
                .thenComparing(TimelineTaskProjection::startDateTime, Comparator.nullsLast(Comparator.naturalOrder()))
                .thenComparing(TimelineTaskProjection::title, Comparator.nullsLast(String::compareToIgnoreCase));
    }

    public record TimelineTaskProjection(
            UUID id,
            UUID userId,
            UUID templateId,
            String title,
            TaskInstanceStatus status,
            TaskPriority priority,
            TaskSourceType sourceType,
            LocalDate anchorDate,
            LocalDateTime startDateTime,
            LocalDateTime endDateTime,
            LocalDate occurrenceDate,
            LocalDate scheduledDate,
            LocalDateTime dueDateTime,
            Instant startedAt,
            Instant completedAt,
            LocalDate achievedDate,
            Instant missedAt,
            Instant skippedAt,
            Instant rolledOverAt,
            UUID linkedScheduleBlockId,
            UUID rolledOverFromInstanceId,
            UUID rolledOverToInstanceId,
            String lane,
            int sortRank
    ) {
    }
}