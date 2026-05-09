package com.lifeos.backend.task.infrastructure.persistence;

import com.lifeos.backend.task.domain.entity.TaskOccurrenceException;
import com.lifeos.backend.task.domain.enums.TaskOccurrenceExceptionType;
import com.lifeos.backend.task.domain.repository.TaskOccurrenceExceptionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
public class TaskOccurrenceExceptionRepositoryImpl
        implements TaskOccurrenceExceptionRepository {

    private final TaskOccurrenceExceptionJpaRepository jpaRepository;

    @Override
    public TaskOccurrenceException save(TaskOccurrenceException exception) {
        return jpaRepository.save(exception);
    }

    @Override
    public List<TaskOccurrenceException> saveAll(List<TaskOccurrenceException> exceptions) {
        return jpaRepository.saveAll(exceptions);
    }

    @Override
    public Optional<TaskOccurrenceException> findByTemplateIdAndOccurrenceDate(
            UUID templateId,
            LocalDate occurrenceDate
    ) {
        return jpaRepository.findByTemplateIdAndOccurrenceDate(templateId, occurrenceDate);
    }

    @Override
    public boolean existsByTemplateIdAndOccurrenceDate(
            UUID templateId,
            LocalDate occurrenceDate
    ) {
        return jpaRepository.existsByTemplateIdAndOccurrenceDate(templateId, occurrenceDate);
    }

    @Override
    public boolean existsByTemplateIdAndOccurrenceDateAndType(
            UUID templateId,
            LocalDate occurrenceDate,
            TaskOccurrenceExceptionType type
    ) {
        return jpaRepository.existsByTemplateIdAndOccurrenceDateAndType(
                templateId,
                occurrenceDate,
                type
        );
    }

    @Override
    public List<TaskOccurrenceException> findByTemplateIdAndOccurrenceDateBetween(
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
    public List<TaskOccurrenceException> findByUserIdAndTemplateId(
            UUID userId,
            UUID templateId
    ) {
        return jpaRepository.findByUserIdAndTemplateIdOrderByOccurrenceDateDesc(
                userId,
                templateId
        );
    }

    @Override
    public void delete(TaskOccurrenceException exception) {
        jpaRepository.delete(exception);
    }
}