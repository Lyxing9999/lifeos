package com.lifeos.backend.financial.infrastructure.persistence;

import com.lifeos.backend.financial.domain.FinancialEvent;
import com.lifeos.backend.financial.domain.FinancialEventRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
public class FinancialEventRepositoryImpl implements FinancialEventRepository {

    private final FinancialEventJpaRepository jpaRepository;

    @Override
    public FinancialEvent save(FinancialEvent event) {
        return jpaRepository.save(event);
    }

    @Override
    public List<FinancialEvent> saveAll(List<FinancialEvent> events) {
        return jpaRepository.saveAll(events);
    }

    @Override
    public Optional<FinancialEvent> findById(UUID id) {
        return jpaRepository.findById(id);
    }

    @Override
    public List<FinancialEvent> findAll() {
        return jpaRepository.findAll();
    }

    @Override
    public List<FinancialEvent> findByUserId(UUID userId) {
        return jpaRepository.findByUserId(userId);
    }

    @Override
    public List<FinancialEvent> findByUserIdAndEventDateLocalOrderByPaidAtAsc(UUID userId, LocalDate date) {
        return jpaRepository.findByUserIdAndEventDateLocalOrderByPaidAtAsc(userId, date);
    }

    @Override
    public List<FinancialEvent> findByUserIdAndPaidAtBetweenOrderByPaidAtAsc(UUID userId, Instant start, Instant end) {
        return jpaRepository.findByUserIdAndPaidAtBetweenOrderByPaidAtAsc(userId, start, end);
    }

    @Override
    public Optional<FinancialEvent> findByUserIdAndProviderEventId(UUID userId, String providerEventId) {
        return jpaRepository.findByUserIdAndProviderEventId(userId, providerEventId);
    }

    @Override
    public long countByUserIdAndEventDateLocal(UUID userId, LocalDate date) {
        return jpaRepository.countByUserIdAndEventDateLocal(userId, date);
    }

    @Override
    public void delete(FinancialEvent event) {
        jpaRepository.delete(event);
    }

    @Override
    public void deleteById(UUID id) {
        jpaRepository.deleteById(id);
    }
}