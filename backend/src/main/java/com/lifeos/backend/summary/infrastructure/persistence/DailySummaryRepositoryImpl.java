package com.lifeos.backend.summary.infrastructure.persistence;

import com.lifeos.backend.summary.domain.DailySummary;
import com.lifeos.backend.summary.domain.DailySummaryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
public class DailySummaryRepositoryImpl implements DailySummaryRepository {

    private final DailySummaryJpaRepository jpaRepository;

    @Override
    public DailySummary save(DailySummary summary) {
        return jpaRepository.save(summary);
    }

    @Override
    public Optional<DailySummary> findByUserIdAndSummaryDate(UUID userId, LocalDate date) {
        return jpaRepository.findByUserIdAndSummaryDate(userId, date);
    }

    @Override
    public List<DailySummary> findAll() {
        return jpaRepository.findAll();
    }

    @Override
    public void delete(DailySummary summary) {
        jpaRepository.delete(summary);
    }
}