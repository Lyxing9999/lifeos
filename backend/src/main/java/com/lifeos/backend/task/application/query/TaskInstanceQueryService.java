package com.lifeos.backend.task.application.query;

import com.lifeos.backend.common.exception.NotFoundException;
import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.task.domain.entity.CompletionLog;
import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.task.domain.repository.CompletionLogRepository;
import com.lifeos.backend.task.domain.repository.TaskInstanceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Read-side service for TaskInstance.
 *
 * TaskInstance = actual executable occurrence.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class TaskInstanceQueryService {

    private final TaskInstanceRepository taskInstanceRepository;
    private final CompletionLogRepository completionLogRepository;
    private final UserTimeService userTimeService;

    public TaskInstance getByIdForUser(UUID userId, UUID taskInstanceId) {
        validateUserId(userId);
        validateInstanceId(taskInstanceId);

        return taskInstanceRepository.findByIdForUser(userId, taskInstanceId)
                .orElseThrow(() -> new NotFoundException("Task instance not found"));
    }

    public List<TaskInstance> getByScheduledDate(UUID userId, LocalDate date) {
        validateUserId(userId);
        LocalDate targetDate = resolveUserDate(userId, date);

        return taskInstanceRepository.findByUserIdAndScheduledDate(userId, targetDate)
                .stream()
                .sorted(instanceComparator())
                .toList();
    }

    public List<TaskInstance> getByScheduledDateRange(
            UUID userId,
            LocalDate startDate,
            LocalDate endDate
    ) {
        validateUserId(userId);
        validateDateRange(startDate, endDate);

        return taskInstanceRepository.findByUserIdAndScheduledDateBetween(
                        userId,
                        startDate,
                        endDate
                )
                .stream()
                .sorted(instanceComparator())
                .toList();
    }

    public List<TaskInstance> getInbox(UUID userId) {
        validateUserId(userId);

        return taskInstanceRepository.findByUserIdAndStatus(
                        userId,
                        TaskInstanceStatus.INBOX
                )
                .stream()
                .sorted(instanceComparator())
                .toList();
    }

    public List<TaskInstance> getCompletedForDay(UUID userId, LocalDate date) {
        validateUserId(userId);
        LocalDate targetDate = resolveUserDate(userId, date);

        List<CompletionLog> logs = completionLogRepository.findByUserIdAndAchievedDate(
                userId,
                targetDate
        );

        Map<UUID, TaskInstance> byId = new LinkedHashMap<>();

        for (CompletionLog log : logs) {
            if (log.getTaskInstanceId() == null) {
                continue;
            }

            taskInstanceRepository.findByIdForUser(userId, log.getTaskInstanceId())
                    .filter(instance -> instance.getStatus() == TaskInstanceStatus.COMPLETED)
                    .ifPresent(instance -> byId.put(instance.getId(), instance));
        }

        return byId.values()
                .stream()
                .filter(instance -> instance.getDoneClearedAt() == null)
                .sorted(completedComparator())
                .toList();
    }

    /**
     * Permanent completed history.
     *
     * Unlike Done view, this does not hide doneClearedAt.
     */
    public List<TaskInstance> getCompletionHistoryForDay(UUID userId, LocalDate date) {
        validateUserId(userId);
        LocalDate targetDate = resolveUserDate(userId, date);

        List<CompletionLog> logs = completionLogRepository.findByUserIdAndAchievedDate(
                userId,
                targetDate
        );

        Map<UUID, TaskInstance> byId = new LinkedHashMap<>();

        for (CompletionLog log : logs) {
            if (log.getTaskInstanceId() == null) {
                continue;
            }

            taskInstanceRepository.findByIdForUser(userId, log.getTaskInstanceId())
                    .ifPresent(instance -> byId.put(instance.getId(), instance));
        }

        return byId.values()
                .stream()
                .sorted(completedComparator())
                .toList();
    }

    public List<TaskInstance> getOverdue(UUID userId) {
        validateUserId(userId);

        return taskInstanceRepository.findByUserIdAndStatus(
                        userId,
                        TaskInstanceStatus.OVERDUE
                )
                .stream()
                .sorted(instanceComparator())
                .toList();
    }

    public List<TaskInstance> getPaused(UUID userId) {
        validateUserId(userId);

        return taskInstanceRepository.findByUserIdAndStatus(
                        userId,
                        TaskInstanceStatus.PAUSED
                )
                .stream()
                .sorted(instanceComparator())
                .toList();
    }

    public List<TaskInstance> getArchived(UUID userId) {
        validateUserId(userId);

        return taskInstanceRepository.findByUserIdAndStatus(
                        userId,
                        TaskInstanceStatus.ARCHIVED
                )
                .stream()
                .sorted(instanceComparator())
                .toList();
    }

    public List<TaskInstance> getMissed(UUID userId) {
        validateUserId(userId);

        return taskInstanceRepository.findByUserIdAndStatus(
                        userId,
                        TaskInstanceStatus.MISSED
                )
                .stream()
                .sorted(instanceComparator())
                .toList();
    }

    public List<TaskInstance> getSkipped(UUID userId) {
        validateUserId(userId);

        return taskInstanceRepository.findByUserIdAndStatus(
                        userId,
                        TaskInstanceStatus.SKIPPED
                )
                .stream()
                .sorted(instanceComparator())
                .toList();
    }

    public List<TaskInstance> getActiveForDay(UUID userId, LocalDate date) {
        validateUserId(userId);
        LocalDate targetDate = resolveUserDate(userId, date);

        return taskInstanceRepository.findByUserIdAndScheduledDate(userId, targetDate)
                .stream()
                .filter(instance -> instance.getStatus() != TaskInstanceStatus.COMPLETED)
                .filter(instance -> instance.getStatus() != TaskInstanceStatus.ROLLED_OVER)
                .filter(instance -> instance.getStatus() != TaskInstanceStatus.MISSED)
                .filter(instance -> instance.getStatus() != TaskInstanceStatus.SKIPPED)
                .filter(instance -> instance.getStatus() != TaskInstanceStatus.ARCHIVED)
                .filter(instance -> instance.getStatus() != TaskInstanceStatus.CANCELLED)
                .sorted(instanceComparator())
                .toList();
    }

    /**
     * Day truth = active tasks for day + completion history for day.
     *
     * This is useful for Timeline/Summary/Score later.
     */
    public List<TaskInstance> getDayTruth(UUID userId, LocalDate date) {
        validateUserId(userId);
        LocalDate targetDate = resolveUserDate(userId, date);

        Map<UUID, TaskInstance> byId = new LinkedHashMap<>();

        getActiveForDay(userId, targetDate)
                .forEach(instance -> byId.put(instance.getId(), instance));

        getCompletionHistoryForDay(userId, targetDate)
                .forEach(instance -> byId.put(instance.getId(), instance));

        return byId.values()
                .stream()
                .sorted(instanceComparator())
                .toList();
    }

    private LocalDate resolveUserDate(UUID userId, LocalDate date) {
        if (date != null) {
            return date;
        }

        return Instant.now()
                .atZone(userTimeService.getUserZoneId(userId))
                .toLocalDate();
    }

    private Comparator<TaskInstance> instanceComparator() {
        return Comparator
                .comparingInt((TaskInstance i) -> statusRank(i.getStatus()))
                .thenComparingInt(i -> i.getPrioritySnapshot() == null ? 99 : i.getPrioritySnapshot().rank())
                .thenComparing(TaskInstance::getDueDateTime, Comparator.nullsLast(Comparator.naturalOrder()))
                .thenComparing(TaskInstance::getScheduledDate, Comparator.nullsLast(Comparator.naturalOrder()))
                .thenComparing(TaskInstance::getTitleSnapshot, Comparator.nullsLast(String::compareToIgnoreCase));
    }

    private Comparator<TaskInstance> completedComparator() {
        return Comparator
                .comparing(TaskInstance::getCompletedAt, Comparator.nullsLast(Comparator.reverseOrder()))
                .thenComparing(TaskInstance::getTitleSnapshot, Comparator.nullsLast(String::compareToIgnoreCase));
    }

    private int statusRank(TaskInstanceStatus status) {
        if (status == null) {
            return 99;
        }

        return switch (status) {
            case OVERDUE -> 0;
            case DUE_TODAY -> 1;
            case IN_PROGRESS -> 2;
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

    private void validateUserId(UUID userId) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }
    }

    private void validateInstanceId(UUID taskInstanceId) {
        if (taskInstanceId == null) {
            throw new IllegalArgumentException("taskInstanceId is required");
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
}