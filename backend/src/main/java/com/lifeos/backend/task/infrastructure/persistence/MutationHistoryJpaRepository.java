package com.lifeos.backend.task.infrastructure.persistence;

import com.lifeos.backend.task.domain.entity.MutationHistory;
import com.lifeos.backend.task.domain.enums.MutationType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface MutationHistoryJpaRepository extends JpaRepository<MutationHistory, UUID> {

    List<MutationHistory> findByUserIdOrderByOccurredAtDesc(UUID userId);

    List<MutationHistory> findByTemplateIdOrderByOccurredAtDesc(UUID templateId);

    List<MutationHistory> findByTaskInstanceIdOrderByOccurredAtDesc(UUID taskInstanceId);

    List<MutationHistory> findByUserIdAndOccurredAtBetweenOrderByOccurredAtDesc(
            UUID userId,
            Instant start,
            Instant end
    );

    List<MutationHistory> findByUserIdAndMutationTypeOrderByOccurredAtDesc(
            UUID userId,
            MutationType mutationType
    );
}