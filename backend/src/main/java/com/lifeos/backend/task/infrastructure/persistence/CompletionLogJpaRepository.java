package com.lifeos.backend.task.infrastructure.persistence;

import com.lifeos.backend.task.domain.entity.CompletionLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface CompletionLogJpaRepository extends JpaRepository<CompletionLog, UUID> {

    Optional<CompletionLog> findByTaskInstanceId(UUID taskInstanceId);

    List<CompletionLog> findByTemplateIdOrderByCompletedAtDesc(UUID templateId);

    List<CompletionLog> findByUserIdAndAchievedDateOrderByCompletedAtDesc(
            UUID userId,
            LocalDate achievedDate
    );

    List<CompletionLog> findByUserIdAndAchievedDateBetweenOrderByAchievedDateDescCompletedAtDesc(
            UUID userId,
            LocalDate startDate,
            LocalDate endDate
    );
}