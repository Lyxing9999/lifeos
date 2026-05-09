package com.lifeos.backend.task.domain.repository;

import com.lifeos.backend.task.domain.entity.CompletionLog;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface CompletionLogRepository {

    CompletionLog save(CompletionLog completionLog);

    List<CompletionLog> saveAll(List<CompletionLog> completionLogs);

    Optional<CompletionLog> findByTaskInstanceId(UUID taskInstanceId);

    List<CompletionLog> findByTemplateId(UUID templateId);

    List<CompletionLog> findByUserIdAndAchievedDate(
            UUID userId,
            LocalDate achievedDate
    );

    List<CompletionLog> findByUserIdAndAchievedDateBetween(
            UUID userId,
            LocalDate startDate,
            LocalDate endDate
    );
}