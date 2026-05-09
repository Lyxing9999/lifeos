package com.lifeos.backend.task.application.query;

import com.lifeos.backend.common.util.UserTimeService;
import com.lifeos.backend.task.domain.entity.MutationHistory;
import com.lifeos.backend.task.domain.enums.MutationType;
import com.lifeos.backend.task.domain.repository.MutationHistoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;
import java.util.UUID;

/**
 * Read-side service for mutation/audit history.
 *
 * Useful for:
 * - dogfooding trust
 * - debug
 * - timeline
 * - AI explanation later
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class TaskMutationHistoryQueryService {

    private final MutationHistoryRepository mutationHistoryRepository;
    private final UserTimeService userTimeService;

    public List<MutationHistory> getByUser(UUID userId) {
        validateUserId(userId);
        return mutationHistoryRepository.findByUserId(userId);
    }

    public List<MutationHistory> getByTemplate(UUID templateId) {
        if (templateId == null) {
            throw new IllegalArgumentException("templateId is required");
        }

        return mutationHistoryRepository.findByTemplateId(templateId);
    }

    public List<MutationHistory> getByInstance(UUID taskInstanceId) {
        if (taskInstanceId == null) {
            throw new IllegalArgumentException("taskInstanceId is required");
        }

        return mutationHistoryRepository.findByTaskInstanceId(taskInstanceId);
    }

    public List<MutationHistory> getByUserAndDate(UUID userId, LocalDate date) {
        validateUserId(userId);

        if (date == null) {
            throw new IllegalArgumentException("date is required");
        }

        ZoneId zoneId = userTimeService.getUserZoneId(userId);

        Instant start = date.atStartOfDay(zoneId).toInstant();
        Instant end = date.plusDays(1).atStartOfDay(zoneId).toInstant();

        return mutationHistoryRepository.findByUserIdAndOccurredAtBetween(
                userId,
                start,
                end
        );
    }

    public List<MutationHistory> getByUserAndMutationType(
            UUID userId,
            MutationType mutationType
    ) {
        validateUserId(userId);

        if (mutationType == null) {
            throw new IllegalArgumentException("mutationType is required");
        }

        return mutationHistoryRepository.findByUserIdAndMutationType(
                userId,
                mutationType
        );
    }

    private void validateUserId(UUID userId) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }
    }
}