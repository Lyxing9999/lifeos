package com.lifeos.backend.task.infrastructure.persistence;

import com.lifeos.backend.task.domain.Task;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public interface TaskJpaRepository extends JpaRepository<Task, UUID> {

    @EntityGraph(attributePaths = {"tags"})
    List<Task> findByUserId(UUID userId);

    @EntityGraph(attributePaths = {"tags"})
    List<Task> findByUserIdAndDueDate(UUID userId, LocalDate dueDate);

    @EntityGraph(attributePaths = {"tags"})
    List<Task> findByUserIdAndDueDateBetweenAndArchivedFalse(UUID userId, LocalDate startDate, LocalDate endDate);

    @EntityGraph(attributePaths = {"tags"})
    List<Task> findByUserIdAndArchivedFalse(UUID userId);

    @EntityGraph(attributePaths = {"tags"})
    List<Task> findByUserIdAndDueDateAndArchivedFalse(UUID userId, LocalDate dueDate);
}