package com.lifeos.backend.summary.domain;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface DailySummaryRepository {
    DailySummary save(DailySummary summary);
    Optional<DailySummary> findByUserIdAndSummaryDate(UUID userId, LocalDate date);
    List<DailySummary> findAll();
    void delete(DailySummary summary);
}