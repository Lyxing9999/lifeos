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
    public ScheduleBlock save(ScheduleBlock block) { return jpaRepository.save(block); }

    @Override
    public List<ScheduleBlock> saveAll(List<ScheduleBlock> blocks) { return jpaRepository.saveAll(blocks); }

    @Override
    public Optional<ScheduleBlock> findById(UUID id) { return jpaRepository.findById(id); }

    @Override
    public void deleteById(UUID id) { jpaRepository.deleteById(id); }

    @Override
    public List<ScheduleBlock> findAll() { return jpaRepository.findAll(); }

    @Override
    public List<ScheduleBlock> findUnarchivedByUserId(UUID userId) {
        return jpaRepository.findByUserIdAndArchivedFalseOrderByStartTimeAsc(userId);
    }

    @Override
    public List<ScheduleBlock> findArchivedByUserId(UUID userId) {
        return jpaRepository.findByUserIdAndArchivedTrueOrderByStartTimeAsc(userId);
    }
}