package com.lifeos.backend.task.infrastructure.persistence;

import com.lifeos.backend.task.domain.Task;
import com.lifeos.backend.task.domain.enums.TaskStatus;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public interface TaskJpaRepository extends JpaRepository<Task, UUID> {

    @EntityGraph(attributePaths = {"tags"})
    List<Task> findByUserId(UUID userId);

    @EntityGraph(attributePaths = {"tags"})
    List<Task> findByUserIdAndDueDate(UUID userId, LocalDate dueDate);

    @EntityGraph(attributePaths = {"tags"})
    List<Task> findByUserIdAndDueDateBetweenAndArchivedFalse(
            UUID userId,
            LocalDate startDate,
            LocalDate endDate
    );
    // Add this inside TaskJpaRepository
    @EntityGraph(attributePaths = {"tags"})
    @Query("""
        SELECT t FROM Task t 
        WHERE t.userId = :userId 
        AND t.archived = false 
        AND t.paused = false
        AND (
            (t.recurrenceRule.type != 'NONE') 
            OR 
            (t.status NOT IN ('COMPLETED', 'CANCELLED'))
        )
    """)
    List<Task> findActiveAndRecurringTasks(@Param("userId") UUID userId);
    @EntityGraph(attributePaths = {"tags"})
    List<Task> findByUserIdAndArchivedFalse(UUID userId);

    @EntityGraph(attributePaths = {"tags"})
    List<Task> findByUserIdAndArchivedTrue(UUID userId);

    @EntityGraph(attributePaths = {"tags"})
    List<Task> findByUserIdAndDueDateAndArchivedFalse(
            UUID userId,
            LocalDate dueDate
    );

    @EntityGraph(attributePaths = {"tags"})
    List<Task> findByUserIdAndArchivedFalseAndStatusAndCompletedAtGreaterThanEqualAndCompletedAtLessThan(
            UUID userId,
            TaskStatus status,
            Instant start,
            Instant end
    );
}