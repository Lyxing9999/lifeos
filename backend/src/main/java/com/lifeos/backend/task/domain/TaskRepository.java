package com.lifeos.backend.task.domain;

import com.lifeos.backend.task.domain.enums.TaskStatus;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface TaskRepository {

    Task save(Task task);

    List<Task> saveAll(List<Task> tasks);

    Optional<Task> findById(UUID id);

    List<Task> findByUserId(UUID userId);

    List<Task> findByUserIdAndDueDate(UUID userId, LocalDate dueDate);

    List<Task> findByUserIdAndDueDateBetweenAndArchivedFalse(
            UUID userId,
            LocalDate startDate,
            LocalDate endDate
    );

    List<Task> findByUserIdAndArchivedFalse(UUID userId);

    List<Task> findByUserIdAndArchivedTrue(UUID userId);
    List<Task> findActiveAndRecurringTasks(UUID userId);
    List<Task> findByUserIdAndDueDateAndArchivedFalse(
            UUID userId,
            LocalDate dueDate
    );

    List<Task> findByUserIdAndArchivedFalseAndStatusAndCompletedAtGreaterThanEqualAndCompletedAtLessThan(
            UUID userId,
            TaskStatus status,
            Instant start,
            Instant end
    );

    void deleteById(UUID id);
}