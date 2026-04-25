package com.lifeos.backend.location.domain;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface LocationLogRepository {

    LocationLog save(LocationLog log);

    List<LocationLog> saveAll(List<LocationLog> logs);

    Optional<LocationLog> findById(UUID id);

    List<LocationLog> findByUserIdAndRecordedAtBetween(UUID userId, Instant start, Instant end);
}