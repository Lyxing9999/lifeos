package com.lifeos.backend.staysession.domain;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface StaySessionRepository {

    StaySession save(StaySession session);

    List<StaySession> saveAll(List<StaySession> sessions);

    List<StaySession> findByUserIdAndStartTimeBetween(UUID userId, Instant start, Instant end);

    void deleteByUserIdAndStartTimeBetween(UUID userId, Instant start, Instant end);
}