package com.lifeos.backend.schedule.infrastructure.persistence;

import com.lifeos.backend.schedule.domain.entity.ScheduleTemplate;
import com.lifeos.backend.schedule.domain.enums.ScheduleTemplateStatus;
import com.lifeos.backend.schedule.domain.repository.ScheduleTemplateRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
public class ScheduleTemplateRepositoryImpl implements ScheduleTemplateRepository {

    private final ScheduleTemplateJpaRepository jpaRepository;

    @Override
    public ScheduleTemplate save(ScheduleTemplate template) {
        return jpaRepository.save(template);
    }

    @Override
    public List<ScheduleTemplate> saveAll(List<ScheduleTemplate> templates) {
        return jpaRepository.saveAll(templates);
    }

    @Override
    public Optional<ScheduleTemplate> findById(UUID templateId) {
        return jpaRepository.findById(templateId);
    }

    @Override
    public Optional<ScheduleTemplate> findByIdForUser(UUID userId, UUID templateId) {
        return jpaRepository.findById(templateId)
                .filter(template -> template.getUserId().equals(userId));
    }

    @Override
    public List<ScheduleTemplate> findByUserId(UUID userId) {
        return jpaRepository.findByUserIdOrderByStartTimeAscCreatedAtDesc(userId);
    }

    @Override
    public List<ScheduleTemplate> findActiveByUserId(UUID userId) {
        return jpaRepository.findByUserIdAndStatusOrderByStartTimeAscCreatedAtDesc(
                userId,
                ScheduleTemplateStatus.ACTIVE
        );
    }

    @Override
    public List<ScheduleTemplate> findPausedByUserId(UUID userId) {
        return jpaRepository.findByUserIdAndStatusOrderByStartTimeAscCreatedAtDesc(
                userId,
                ScheduleTemplateStatus.PAUSED
        );
    }

    @Override
    public List<ScheduleTemplate> findArchivedByUserId(UUID userId) {
        return jpaRepository.findByUserIdAndStatusOrderByStartTimeAscCreatedAtDesc(
                userId,
                ScheduleTemplateStatus.ARCHIVED
        );
    }

    @Override
    public List<ScheduleTemplate> findSpawnCandidates(
            UUID userId,
            LocalDate windowStart,
            LocalDate windowEnd
    ) {
        return jpaRepository.findSpawnCandidates(
                userId,
                ScheduleTemplateStatus.ACTIVE,
                windowStart,
                windowEnd
        );
    }

    @Override
    public void deleteById(UUID templateId) {
        jpaRepository.deleteById(templateId);
    }
}