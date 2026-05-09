package com.lifeos.backend.task.application.query;

import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.task.domain.entity.TaskInstance;
import com.lifeos.backend.task.domain.enums.TaskInstanceStatus;
import com.lifeos.backend.task.domain.repository.TaskInstanceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Query service for engine overdue/missed/rollover candidates.
 *
 * This service only finds candidates.
 * The engine/processor decides which transition to apply.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class OverdueTaskQueryService {

    private final TaskInstanceRepository taskInstanceRepository;
    private final UserTimeService userTimeService;

    public List<TaskInstance> getOverdueCandidatesNow(UUID userId) {
        LocalDate today = resolveUserToday(userId);
        LocalDateTime nowLocal = resolveUserNowLocal(userId);

        return taskInstanceRepository.findOverdueCandidates(
                userId,
                today,
                nowLocal,
                openStatuses()
        );
    }

    public List<TaskInstance> getOpenInstancesForDayBoundary(
            UUID userId,
            LocalDate targetDate
    ) {
        LocalDate safeTargetDate = targetDate == null
                ? resolveUserToday(userId).minusDays(1)
                : targetDate;

        LocalDateTime endExclusive = safeTargetDate.plusDays(1).atStartOfDay();

        return taskInstanceRepository.findOpenInstancesForDayBoundary(
                userId,
                safeTargetDate,
                endExclusive,
                openStatuses()
        );
    }

    public List<TaskInstance> getCurrentOverdue(UUID userId) {
        return taskInstanceRepository.findByUserIdAndStatus(
                userId,
                TaskInstanceStatus.OVERDUE
        );
    }

    private List<TaskInstanceStatus> openStatuses() {
        return List.of(
                TaskInstanceStatus.INBOX,
                TaskInstanceStatus.SCHEDULED,
                TaskInstanceStatus.DUE_TODAY,
                TaskInstanceStatus.IN_PROGRESS,
                TaskInstanceStatus.OVERDUE
        );
    }

    private LocalDate resolveUserToday(UUID userId) {
        return Instant.now()
                .atZone(userTimeService.getUserZoneId(userId))
                .toLocalDate();
    }

    private LocalDateTime resolveUserNowLocal(UUID userId) {
        return Instant.now()
                .atZone(userTimeService.getUserZoneId(userId))
                .toLocalDateTime();
    }
}