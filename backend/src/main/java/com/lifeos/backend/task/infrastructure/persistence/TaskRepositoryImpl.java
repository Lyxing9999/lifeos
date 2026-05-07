package com.lifeos.backend.task.infrastructure.persistence;

import com.lifeos.backend.task.domain.Task;
import com.lifeos.backend.task.domain.TaskRepository;
import com.lifeos.backend.task.domain.enums.TaskStatus;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
public class TaskRepositoryImpl implements TaskRepository {

    private final TaskJpaRepository taskJpaRepository;

    @Override
    public Task save(Task task) {
        return taskJpaRepository.save(task);
    }

    @Override
    public List<Task> saveAll(List<Task> tasks) {
        return taskJpaRepository.saveAll(tasks);
    }

    @Override
    public Optional<Task> findById(UUID id) {
        return taskJpaRepository.findById(id);
    }

    @Override
    public List<Task> findByUserId(UUID userId) {
        return taskJpaRepository.findByUserId(userId);
    }

    @Override
    public List<Task> findByUserIdAndDueDate(UUID userId, LocalDate dueDate) {
        return taskJpaRepository.findByUserIdAndDueDate(userId, dueDate);
    }

    @Override
    public List<Task> findByUserIdAndDueDateBetweenAndArchivedFalse(
            UUID userId,
            LocalDate startDate,
            LocalDate endDate
    ) {
        return taskJpaRepository.findByUserIdAndDueDateBetweenAndArchivedFalse(
                userId,
                startDate,
                endDate
        );
    }
    @Override
    public List<Task> findActiveAndRecurringTasks(UUID userId) {
        return taskJpaRepository.findActiveAndRecurringTasks(userId);
    }
    @Override
    public List<Task> findByUserIdAndArchivedFalse(UUID userId) {
        return taskJpaRepository.findByUserIdAndArchivedFalse(userId);
    }

    @Override
    public List<Task> findByUserIdAndArchivedTrue(UUID userId) {
        return taskJpaRepository.findByUserIdAndArchivedTrue(userId);
    }

    @Override
    public List<Task> findByUserIdAndDueDateAndArchivedFalse(
            UUID userId,
            LocalDate dueDate
    ) {
        return taskJpaRepository.findByUserIdAndDueDateAndArchivedFalse(
                userId,
                dueDate
        );
    }

    @Override
    public List<Task> findByUserIdAndArchivedFalseAndStatusAndCompletedAtGreaterThanEqualAndCompletedAtLessThan(
            UUID userId,
            TaskStatus status,
            Instant start,
            Instant end
    ) {
        return taskJpaRepository
                .findByUserIdAndArchivedFalseAndStatusAndCompletedAtGreaterThanEqualAndCompletedAtLessThan(
                        userId,
                        status,
                        start,
                        end
                );
    }

    @Override
    public void deleteById(UUID id) {
        taskJpaRepository.deleteById(id);
    }
}