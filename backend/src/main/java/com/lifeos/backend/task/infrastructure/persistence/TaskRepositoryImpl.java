package com.lifeos.backend.task.infrastructure.persistence;

import com.lifeos.backend.task.domain.Task;
import com.lifeos.backend.task.domain.TaskRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
public class TaskRepositoryImpl implements TaskRepository {

    private final TaskJpaRepository jpaRepository;

    @Override
    public Task save(Task task) {
        return jpaRepository.save(task);
    }

    @Override
    public List<Task> saveAll(List<Task> tasks) {
        return jpaRepository.saveAll(tasks);
    }

    @Override
    public Optional<Task> findById(UUID id) {
        return jpaRepository.findById(id);
    }

    @Override
    public List<Task> findByUserId(UUID userId) {
        return jpaRepository.findByUserId(userId);
    }

    @Override
    public List<Task> findByUserIdAndDueDate(UUID userId, LocalDate dueDate) {
        return jpaRepository.findByUserIdAndDueDate(userId, dueDate);
    }

    @Override
    public List<Task> findByUserIdAndDueDateBetweenAndArchivedFalse(UUID userId, LocalDate startDate, LocalDate endDate) {
        return jpaRepository.findByUserIdAndDueDateBetweenAndArchivedFalse(userId, startDate, endDate);
    }

    @Override
    public List<Task> findByUserIdAndArchivedFalse(UUID userId) {
        return jpaRepository.findByUserIdAndArchivedFalse(userId);
    }

    @Override
    public List<Task> findByUserIdAndDueDateAndArchivedFalse(UUID userId, LocalDate dueDate) {
        return jpaRepository.findByUserIdAndDueDateAndArchivedFalse(userId, dueDate);
    }

    @Override
    public void deleteById(UUID id) {
        jpaRepository.deleteById(id);
    }
}