package com.lifeos.backend.score.infrastructure.persistence;

import com.lifeos.backend.score.domain.DailyScore;
import com.lifeos.backend.score.domain.DailyScoreRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
public class DailyScoreRepositoryImpl implements DailyScoreRepository {

    private final DailyScoreJpaRepository jpaRepository;

    @Override
    public DailyScore save(DailyScore score) {
        return jpaRepository.save(score);
    }

    @Override
    public Optional<DailyScore> findByUserIdAndScoreDate(UUID userId, LocalDate scoreDate) {
        return jpaRepository.findByUserIdAndScoreDate(userId, scoreDate);
    }

    @Override
    public void delete(DailyScore score) {
        jpaRepository.delete(score);
    }
}