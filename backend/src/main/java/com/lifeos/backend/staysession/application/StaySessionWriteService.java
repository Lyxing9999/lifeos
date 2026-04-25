package com.lifeos.backend.staysession.application;

import com.lifeos.backend.staysession.domain.StaySession;
import com.lifeos.backend.staysession.domain.StaySessionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class StaySessionWriteService {

    private final StaySessionRepository repository;

    public StaySession save(StaySession session) {
        validate(session);

        StaySession saved = repository.save(session);

        log.info(
                "stay_session_saved userId={} staySessionId={} startTime={} endTime={} durationMinutes={} placeName={} source={}",
                saved.getUserId(),
                saved.getId(),
                saved.getStartTime(),
                saved.getEndTime(),
                saved.getDurationMinutes(),
                saved.getPlaceName(),
                saved.getMatchedPlaceSource()
        );

        return saved;
    }

    public List<StaySession> saveAll(List<StaySession> sessions) {
        if (sessions == null || sessions.isEmpty()) {
            return List.of();
        }

        sessions.forEach(this::validate);

        List<StaySession> saved = repository.saveAll(sessions);

        log.info("stay_session_batch_saved count={}", saved.size());

        return saved;
    }

    private void validate(StaySession session) {
        if (session == null) {
            throw new IllegalArgumentException("Stay session is required");
        }

        if (session.getUserId() == null) {
            throw new IllegalArgumentException("Stay session userId is required");
        }

        if (session.getStartTime() == null || session.getEndTime() == null) {
            throw new IllegalArgumentException("Stay session startTime and endTime are required");
        }

        if (!session.getEndTime().isAfter(session.getStartTime())) {
            throw new IllegalArgumentException("Stay session endTime must be after startTime");
        }

        if (session.getDurationMinutes() == null || session.getDurationMinutes() < 0) {
            throw new IllegalArgumentException("Stay session durationMinutes must be >= 0");
        }

        if (session.getCenterLat() == null || session.getCenterLng() == null) {
            throw new IllegalArgumentException("Stay session centerLat and centerLng are required");
        }

        if (session.getConfidence() == null) {
            session.setConfidence(0.0);
        }

        if (session.getMatchedPlaceSource() == null || session.getMatchedPlaceSource().isBlank()) {
            session.setMatchedPlaceSource("UNKNOWN");
        }

        if (session.getPlaceName() == null || session.getPlaceName().isBlank()) {
            session.setPlaceName("Unknown Place");
        }

        if (session.getPlaceType() == null || session.getPlaceType().isBlank()) {
            session.setPlaceType("OTHER");
        }
    }
}