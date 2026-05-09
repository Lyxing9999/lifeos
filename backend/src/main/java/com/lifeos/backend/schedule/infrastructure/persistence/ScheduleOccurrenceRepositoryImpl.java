package com.lifeos.backend.schedule.infrastructure.persistence;

import com.lifeos.backend.schedule.domain.entity.ScheduleOccurrence;
import com.lifeos.backend.schedule.domain.enums.ScheduleOccurrenceStatus;
import com.lifeos.backend.schedule.domain.repository.ScheduleOccurrenceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
public class ScheduleOccurrenceRepositoryImpl implements ScheduleOccurrenceRepository {

    private final ScheduleOccurrenceJpaRepository jpaRepository;

    @Override
    public ScheduleOccurrence save(ScheduleOccurrence occurrence) {
        return jpaRepository.save(occurrence);
    }

    @Override
    public List<ScheduleOccurrence> saveAll(List<ScheduleOccurrence> occurrences) {
        return jpaRepository.saveAll(occurrences);
    }

    @Override
    public Optional<ScheduleOccurrence> findById(UUID occurrenceId) {
        return jpaRepository.findById(occurrenceId);
    }

    @Override
    public Optional<ScheduleOccurrence> findByIdForUser(UUID userId, UUID occurrenceId) {
        return jpaRepository.findByIdAndUserId(occurrenceId, userId);
    }

    @Override
    public Optional<ScheduleOccurrence> findByTemplateIdAndOccurrenceDate(
            UUID templateId,
            LocalDate occurrenceDate
    ) {
        return jpaRepository.findByTemplateIdAndOccurrenceDate(
                templateId,
                occurrenceDate
        );
    }

    @Override
    public boolean existsByTemplateIdAndOccurrenceDate(
            UUID templateId,
            LocalDate occurrenceDate
    ) {
        return jpaRepository.existsByTemplateIdAndOccurrenceDate(
                templateId,
                occurrenceDate
        );
    }

    @Override
    public List<ScheduleOccurrence> findByUserIdAndOccurrenceDate(
            UUID userId,
            LocalDate occurrenceDate
    ) {
        return jpaRepository.findByUserIdAndOccurrenceDateOrderByStartDateTimeAsc(
                userId,
                occurrenceDate
        );
    }

    @Override
    public List<ScheduleOccurrence> findByUserIdAndScheduledDate(
            UUID userId,
            LocalDate scheduledDate
    ) {
        return jpaRepository.findByUserIdAndScheduledDateOrderByStartDateTimeAsc(
                userId,
                scheduledDate
        );
    }

    @Override
    public List<ScheduleOccurrence> findByUserIdAndScheduledDateBetween(
            UUID userId,
            LocalDate startDate,
            LocalDate endDate
    ) {
        return jpaRepository.findByUserIdAndScheduledDateBetweenOrderByStartDateTimeAsc(
                userId,
                startDate,
                endDate
        );
    }

    @Override
    public List<ScheduleOccurrence> findByUserIdAndStatus(
            UUID userId,
            ScheduleOccurrenceStatus status
    ) {
        return jpaRepository.findByUserIdAndStatusOrderByStartDateTimeAsc(
                userId,
                status
        );
    }

    @Override
    public List<ScheduleOccurrence> findOverlapping(
            UUID userId,
            LocalDateTime startDateTime,
            LocalDateTime endDateTime
    ) {
        return jpaRepository.findOverlapping(
                userId,
                startDateTime,
                endDateTime,
                List.of(
                        ScheduleOccurrenceStatus.PLANNED,
                        ScheduleOccurrenceStatus.ACTIVE
                )
        );
    }

    @Override
    public List<ScheduleOccurrence> findOpenOccurrencesBefore(
            UUID userId,
            LocalDateTime nowLocalDateTime,
            List<ScheduleOccurrenceStatus> statuses
    ) {
        return jpaRepository.findOpenOccurrencesBefore(
                userId,
                nowLocalDateTime,
                statuses
        );
    }

    @Override
    public List<ScheduleOccurrence> findOccurrencesActiveAt(
            UUID userId,
            LocalDateTime nowLocalDateTime,
            List<ScheduleOccurrenceStatus> statuses
    ) {
        return jpaRepository.findOccurrencesActiveAt(
                userId,
                nowLocalDateTime,
                statuses
        );
    }

    @Override
    public List<ScheduleOccurrence> findByRescheduledFromOccurrenceId(UUID sourceOccurrenceId) {
        return jpaRepository.findByRescheduledFromOccurrenceId(sourceOccurrenceId);
    }

    @Override
    public List<ScheduleOccurrence> findByRescheduledToOccurrenceId(UUID targetOccurrenceId) {
        return jpaRepository.findByRescheduledToOccurrenceId(targetOccurrenceId);
    }

    @Override
    public void deleteById(UUID occurrenceId) {
        jpaRepository.deleteById(occurrenceId);
    }
}