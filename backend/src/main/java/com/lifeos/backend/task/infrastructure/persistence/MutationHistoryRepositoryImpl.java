package com.lifeos.backend.task.infrastructure.persistence;

import com.lifeos.backend.task.domain.entity.MutationHistory;
import com.lifeos.backend.task.domain.enums.MutationType;
import com.lifeos.backend.task.domain.repository.MutationHistoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
public class MutationHistoryRepositoryImpl implements MutationHistoryRepository {

    private final MutationHistoryJpaRepository jpaRepository;

    @Override
    public MutationHistory save(MutationHistory history) {
        return jpaRepository.save(history);
    }

    @Override
    public List<MutationHistory> saveAll(List<MutationHistory> histories) {
        return jpaRepository.saveAll(histories);
    }

    @Override
    public List<MutationHistory> findByUserId(UUID userId) {
        return jpaRepository.findByUserIdOrderByOccurredAtDesc(userId);
    }

    @Override
    public List<MutationHistory> findByTemplateId(UUID templateId) {
        return jpaRepository.findByTemplateIdOrderByOccurredAtDesc(templateId);
    }

    @Override
    public List<MutationHistory> findByTaskInstanceId(UUID taskInstanceId) {
        return jpaRepository.findByTaskInstanceIdOrderByOccurredAtDesc(taskInstanceId);
    }

    @Override
    public List<MutationHistory> findByUserIdAndOccurredAtBetween(
            UUID userId,
            Instant start,
            Instant end
    ) {
        return jpaRepository.findByUserIdAndOccurredAtBetweenOrderByOccurredAtDesc(
                userId,
                start,
                end
        );
    }

    @Override
    public List<MutationHistory> findByUserIdAndMutationType(
            UUID userId,
            MutationType mutationType
    ) {
        return jpaRepository.findByUserIdAndMutationTypeOrderByOccurredAtDesc(
                userId,
                mutationType
        );
    }
}