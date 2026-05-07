package com.lifeos.backend.financial.infrastructure.persistence;

import com.lifeos.backend.financial.domain.FinancialEvent;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface FinancialEventJpaRepository extends JpaRepository<FinancialEvent, UUID> {

    List<FinancialEvent> findByUserId(UUID userId);

    List<FinancialEvent> findByUserIdAndEventDateLocalOrderByPaidAtAsc(UUID userId, LocalDate date);

    List<FinancialEvent> findByUserIdAndPaidAtBetweenOrderByPaidAtAsc(
            UUID userId,
            Instant start,
            Instant end
    );

    Optional<FinancialEvent> findByUserIdAndProviderEventId(UUID userId, String providerEventId);

    long countByUserIdAndEventDateLocal(UUID userId, LocalDate date);
}