package com.lifeos.backend.schedule.domain.repository;

import com.lifeos.backend.schedule.domain.entity.ScheduleException;
import com.lifeos.backend.schedule.domain.enums.ScheduleExceptionType;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ScheduleExceptionRepository {

    ScheduleException save(ScheduleException exception);

    List<ScheduleException> saveAll(List<ScheduleException> exceptions);

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

    List<ScheduleException> findByTemplateIdAndOccurrenceDateBetween(
            UUID templateId,
            LocalDate startDate,
            LocalDate endDate
    );

    List<ScheduleException> findByUserIdAndTemplateId(
            UUID userId,
            UUID templateId
    );

    void delete(ScheduleException exception);
}