package com.lifeos.backend.summary.infrastructure.persistence;

import com.lifeos.backend.summary.domain.DailySummary;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

public interface DailySummaryJpaRepository extends JpaRepository<DailySummary, UUID> {
    Optional<DailySummary> findByUserIdAndSummaryDate(UUID userId, LocalDate summaryDate);
}