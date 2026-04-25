package com.lifeos.backend.schedule.infrastructure.persistence;

import com.lifeos.backend.schedule.domain.ScheduleBlock;
import com.lifeos.backend.schedule.domain.ScheduleBlockRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
public class ScheduleBlockRepositoryImpl implements ScheduleBlockRepository {

    private final ScheduleBlockJpaRepository jpaRepository;

    @Override
    public ScheduleBlock save(ScheduleBlock block) {
        return jpaRepository.save(block);
    }

    @Override
    public List<ScheduleBlock> saveAll(List<ScheduleBlock> blocks) {
        return jpaRepository.saveAll(blocks);
    }

    @Override
    public Optional<ScheduleBlock> findById(UUID id) {
        return jpaRepository.findById(id);
    }

    @Override
    public List<ScheduleBlock> findByUserId(UUID userId) {
        return jpaRepository.findByUserIdOrderByStartTimeAsc(userId);
    }

    @Override
    public List<ScheduleBlock> findByUserIdAndActiveTrue(UUID userId) {
        return jpaRepository.findByUserIdAndActiveTrueOrderByStartTimeAsc(userId);
    }

    @Override
    public void deleteById(UUID id) {
        jpaRepository.deleteById(id);
    }
}