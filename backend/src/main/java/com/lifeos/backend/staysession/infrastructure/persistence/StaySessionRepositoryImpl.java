package com.lifeos.backend.staysession.infrastructure.persistence;

import com.lifeos.backend.staysession.domain.StaySession;
import com.lifeos.backend.staysession.domain.StaySessionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
public class StaySessionRepositoryImpl implements StaySessionRepository {

    private final StaySessionJpaRepository jpaRepository;

    @Override
    public StaySession save(StaySession session) {
        return jpaRepository.save(session);
    }

    @Override
    public List<StaySession> saveAll(List<StaySession> sessions) {
        return jpaRepository.saveAll(sessions);
    }

    @Override
    public List<StaySession> findByUserIdAndStartTimeBetween(UUID userId, Instant start, Instant end) {
        return jpaRepository.findByUserIdAndStartTimeBetweenOrderByStartTimeAsc(userId, start, end);
    }

    @Override
    public void deleteByUserIdAndStartTimeBetween(UUID userId, Instant start, Instant end) {
        jpaRepository.deleteByUserIdAndStartTimeBetween(userId, start, end);
    }
}