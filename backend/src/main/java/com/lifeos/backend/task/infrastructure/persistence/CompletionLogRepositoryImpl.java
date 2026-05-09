package com.lifeos.backend.task.infrastructure.persistence;

import com.lifeos.backend.task.domain.entity.CompletionLog;
import com.lifeos.backend.task.domain.repository.CompletionLogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
public class CompletionLogRepositoryImpl implements CompletionLogRepository {

    private final CompletionLogJpaRepository jpaRepository;

    @Override
    public CompletionLog save(CompletionLog completionLog) {
        return jpaRepository.save(completionLog);
    }

    @Override
    public List<CompletionLog> saveAll(List<CompletionLog> completionLogs) {
        return jpaRepository.saveAll(completionLogs);
    }

    @Override
    public Optional<CompletionLog> findByTaskInstanceId(UUID taskInstanceId) {
        return jpaRepository.findByTaskInstanceId(taskInstanceId);
    }

    @Override
    public List<CompletionLog> findByTemplateId(UUID templateId) {
        return jpaRepository.findByTemplateIdOrderByCompletedAtDesc(templateId);
    }

    @Override
    public List<CompletionLog> findByUserIdAndAchievedDate(
            UUID userId,
            LocalDate achievedDate
    ) {
        return jpaRepository.findByUserIdAndAchievedDateOrderByCompletedAtDesc(
                userId,
                achievedDate
        );
    }

    @Override
    public List<CompletionLog> findByUserIdAndAchievedDateBetween(
            UUID userId,
            LocalDate startDate,
            LocalDate endDate
    ) {
        return jpaRepository.findByUserIdAndAchievedDateBetweenOrderByAchievedDateDescCompletedAtDesc(
                userId,
                startDate,
                endDate
        );
    }
}