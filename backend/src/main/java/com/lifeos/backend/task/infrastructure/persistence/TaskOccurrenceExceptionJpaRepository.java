package com.lifeos.backend.task.infrastructure.persistence;

import com.lifeos.backend.task.domain.entity.TaskOccurrenceException;
import com.lifeos.backend.task.domain.enums.TaskOccurrenceExceptionType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface TaskOccurrenceExceptionJpaRepository
        extends JpaRepository<TaskOccurrenceException, UUID> {

    Optional<TaskOccurrenceException> findByTemplateIdAndOccurrenceDate(
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
            TaskOccurrenceExceptionType type
    );

    List<TaskOccurrenceException> findByTemplateIdAndOccurrenceDateBetweenOrderByOccurrenceDateAsc(
            UUID templateId,
            LocalDate startDate,
            LocalDate endDate
    );

    List<TaskOccurrenceException> findByUserIdAndTemplateIdOrderByOccurrenceDateDesc(
            UUID userId,
            UUID templateId
    );
}