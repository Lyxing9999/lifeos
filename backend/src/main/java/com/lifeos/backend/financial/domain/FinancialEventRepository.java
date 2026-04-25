package com.lifeos.backend.financial.domain;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface FinancialEventRepository {

    FinancialEvent save(FinancialEvent event);

    List<FinancialEvent> saveAll(List<FinancialEvent> events);

    Optional<FinancialEvent> findById(UUID id);

    List<FinancialEvent> findAll();

    List<FinancialEvent> findByUserId(UUID userId);

    List<FinancialEvent> findByUserIdAndEventDateLocalOrderByPaidAtAsc(UUID userId, LocalDate date);

    List<FinancialEvent> findByUserIdAndPaidAtBetweenOrderByPaidAtAsc(UUID userId, Instant start, Instant end);

    Optional<FinancialEvent> findByUserIdAndProviderEventId(UUID userId, String providerEventId);

    long countByUserIdAndEventDateLocal(UUID userId, LocalDate date);

    void delete(FinancialEvent event);

    void deleteById(UUID id);
}