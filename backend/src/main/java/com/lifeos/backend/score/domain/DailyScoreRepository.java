package com.lifeos.backend.score.domain;

import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

public interface DailyScoreRepository {
    DailyScore save(DailyScore score);
    Optional<DailyScore> findByUserIdAndScoreDate(UUID userId, LocalDate scoreDate);
    void delete(DailyScore score);
}