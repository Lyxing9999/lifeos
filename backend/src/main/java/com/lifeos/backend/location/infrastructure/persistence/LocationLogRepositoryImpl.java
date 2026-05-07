package com.lifeos.backend.location.infrastructure.persistence;

import com.lifeos.backend.location.domain.LocationLog;
import com.lifeos.backend.location.domain.LocationLogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
public class LocationLogRepositoryImpl implements LocationLogRepository {

    private final LocationLogJpaRepository jpaRepository;

    @Override
    public LocationLog save(LocationLog log) {
        return jpaRepository.save(log);
    }

    @Override
    public List<LocationLog> saveAll(List<LocationLog> logs) {
        return jpaRepository.saveAll(logs);
    }

    @Override
    public Optional<LocationLog> findById(UUID id) {
        return jpaRepository.findById(id);
    }

    @Override
    public List<LocationLog> findByUserIdAndRecordedAtBetween(UUID userId, Instant start, Instant end) {
        return jpaRepository.findByUserIdAndRecordedAtBetweenOrderByRecordedAtAsc(userId, start, end);
    }
}