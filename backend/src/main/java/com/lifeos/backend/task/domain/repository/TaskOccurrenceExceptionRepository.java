package com.lifeos.backend.task.domain.repository;

import com.lifeos.backend.task.domain.entity.TaskOccurrenceException;
import com.lifeos.backend.task.domain.enums.TaskOccurrenceExceptionType;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface TaskOccurrenceExceptionRepository {

    TaskOccurrenceException save(TaskOccurrenceException exception);

    List<TaskOccurrenceException> saveAll(List<TaskOccurrenceException> exceptions);

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

    List<TaskOccurrenceException> findByTemplateIdAndOccurrenceDateBetween(
            UUID templateId,
            LocalDate startDate,
            LocalDate endDate
    );

    List<TaskOccurrenceException> findByUserIdAndTemplateId(
            UUID userId,
            UUID templateId
    );

    void delete(TaskOccurrenceException exception);
}