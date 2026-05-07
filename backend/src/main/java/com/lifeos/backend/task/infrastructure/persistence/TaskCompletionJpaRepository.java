package com.lifeos.backend.task.infrastructure.persistence;

import com.lifeos.backend.task.domain.TaskCompletion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface TaskCompletionJpaRepository extends JpaRepository<TaskCompletion, UUID> {

    Optional<TaskCompletion> findByTaskIdAndCompletionDate(UUID taskId, LocalDate completionDate);

    List<TaskCompletion> findByUserIdAndCompletionDate(UUID userId, LocalDate completionDate);

    // Add this projection
    interface DailyCompletionCount {
        LocalDate getCompletionDate();
        int getCount();
    }

    // Add this optimized query
    @Query("""
        SELECT tc.completionDate as completionDate, COUNT(tc.id) as count 
        FROM TaskCompletion tc 
        WHERE tc.userId = :userId 
        AND tc.completionDate >= :startDate 
        AND tc.completionDate <= :endDate
        GROUP BY tc.completionDate
    """)
    List<DailyCompletionCount> countCompletionsByDateRange(
            @Param("userId") UUID userId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate
    );
}