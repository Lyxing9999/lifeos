package com.lifeos.backend.staysession.infrastructure.persistence;

import com.lifeos.backend.staysession.domain.StaySession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface StaySessionJpaRepository extends JpaRepository<StaySession, UUID> {

    List<StaySession> findByUserIdAndStartTimeBetweenOrderByStartTimeAsc(
            UUID userId,
            Instant start,
            Instant end
    );

    @Transactional
    void deleteByUserIdAndStartTimeBetween(UUID userId, Instant start, Instant end);
}