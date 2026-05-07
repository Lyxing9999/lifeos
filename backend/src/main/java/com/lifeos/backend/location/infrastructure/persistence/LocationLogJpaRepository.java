package com.lifeos.backend.location.infrastructure.persistence;

import com.lifeos.backend.location.domain.LocationLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface LocationLogJpaRepository extends JpaRepository<LocationLog, UUID> {

    List<LocationLog> findByUserIdAndRecordedAtBetweenOrderByRecordedAtAsc(
            UUID userId,
            Instant start,
            Instant end
    );
}