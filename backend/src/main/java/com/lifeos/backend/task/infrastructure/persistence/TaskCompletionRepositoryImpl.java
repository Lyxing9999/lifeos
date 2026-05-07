package com.lifeos.backend.task.infrastructure.persistence;

import com.lifeos.backend.task.domain.TaskCompletion;
import com.lifeos.backend.task.domain.TaskCompletionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
public class TaskCompletionRepositoryImpl implements TaskCompletionRepository {

    private final TaskCompletionJpaRepository jpaRepository;

    @Override
    public TaskCompletion save(TaskCompletion completion) {
        return jpaRepository.save(completion);
    }

    @Override
    public List<TaskCompletion> saveAll(List<TaskCompletion> completions) {
        return jpaRepository.saveAll(completions);
    }

    @Override
    public Optional<TaskCompletion> findByTaskIdAndCompletionDate(
            UUID taskId,
            LocalDate completionDate
    ) {
        return jpaRepository.findByTaskIdAndCompletionDate(
                taskId,
                completionDate
        );
    }

    @Override
    public List<TaskCompletion> findByUserIdAndCompletionDate(
            UUID userId,
            LocalDate completionDate
    ) {
        return jpaRepository.findByUserIdAndCompletionDate(
                userId,
                completionDate
        );
    }

    @Override
    public void delete(TaskCompletion completion) {
        jpaRepository.delete(completion);
    }
}