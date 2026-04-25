package com.lifeos.backend.score.infrastructure.persistence;

import com.lifeos.backend.score.domain.DailyScore;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

public interface DailyScoreJpaRepository extends JpaRepository<DailyScore, UUID> {
    Optional<DailyScore> findByUserIdAndScoreDate(UUID userId, LocalDate scoreDate);
}