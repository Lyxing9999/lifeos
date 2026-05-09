package com.lifeos.backend.task.domain.repository;

import com.lifeos.backend.task.domain.entity.MutationHistory;
import com.lifeos.backend.task.domain.enums.MutationType;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface MutationHistoryRepository {

    MutationHistory save(MutationHistory history);

    List<MutationHistory> saveAll(List<MutationHistory> histories);

    List<MutationHistory> findByUserId(
            UUID userId
    );

    List<MutationHistory> findByTemplateId(
            UUID templateId
    );

    List<MutationHistory> findByTaskInstanceId(
            UUID taskInstanceId
    );

    List<MutationHistory> findByUserIdAndOccurredAtBetween(
            UUID userId,
            Instant start,
            Instant end
    );

    List<MutationHistory> findByUserIdAndMutationType(
            UUID userId,
            MutationType mutationType
    );
}