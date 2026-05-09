package com.lifeos.backend.schedule.infrastructure.persistence;

import com.lifeos.backend.schedule.domain.entity.ScheduleException;
import com.lifeos.backend.schedule.domain.enums.ScheduleExceptionType;
import com.lifeos.backend.schedule.domain.repository.ScheduleExceptionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
public class ScheduleExceptionRepositoryImpl implements ScheduleExceptionRepository {

    private final ScheduleExceptionJpaRepository jpaRepository;

    @Override
    public ScheduleException save(ScheduleException exception) {
        return jpaRepository.save(exception);
    }

    @Override
    public List<ScheduleException> saveAll(List<ScheduleException> exceptions) {
        return jpaRepository.saveAll(exceptions);
    }

    @Override
    public Optional<ScheduleException> findByTemplateIdAndOccurrenceDate(
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
    public boolean existsByTemplateIdAndOccurrenceDateAndType(
            UUID templateId,
            LocalDate occurrenceDate,
            ScheduleExceptionType type
    ) {
        return jpaRepository.existsByTemplateIdAndOccurrenceDateAndType(
                templateId,
                occurrenceDate,
                type
        );
    }

    @Override
    public List<ScheduleException> findByTemplateIdAndOccurrenceDateBetween(
            UUID templateId,
            LocalDate startDate,
            LocalDate endDate
    ) {
        return jpaRepository.findByTemplateIdAndOccurrenceDateBetweenOrderByOccurrenceDateAsc(
                templateId,
                startDate,
                endDate
        );
    }

    @Override
    public List<ScheduleException> findByUserIdAndTemplateId(
            UUID userId,
            UUID templateId
    ) {
        return jpaRepository.findByUserIdAndTemplateIdOrderByOccurrenceDateDesc(
                userId,
                templateId
        );
    }

    @Override
    public void delete(ScheduleException exception) {
        jpaRepository.delete(exception);
    }
}