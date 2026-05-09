package com.lifeos.backend.schedule.infrastructure.persistence;

import com.lifeos.backend.schedule.domain.entity.ScheduleException;
import com.lifeos.backend.schedule.domain.enums.ScheduleExceptionType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ScheduleExceptionJpaRepository
        extends JpaRepository<ScheduleException, UUID> {

    Optional<ScheduleException> findByTemplateIdAndOccurrenceDate(
            UUID templateId,
            LocalDate occurrenceDate
    );

    boolean existsByTemplateIdAndOccurrenceDate(
            UUID templateId,
            LocalDate occurrenceDate
    );

    boolean existsByTemplateIdAndOccurrenceDateAndType(
            UUID templateId,
            LocalDate occurrenceDate,
            ScheduleExceptionType type
    );

    List<ScheduleException> findByTemplateIdAndOccurrenceDateBetweenOrderByOccurrenceDateAsc(
            UUID templateId,
            LocalDate startDate,
            LocalDate endDate
    );

    List<ScheduleException> findByUserIdAndTemplateIdOrderByOccurrenceDateDesc(
            UUID userId,
            UUID templateId
    );
}