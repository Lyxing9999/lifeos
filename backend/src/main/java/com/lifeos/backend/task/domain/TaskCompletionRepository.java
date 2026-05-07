package com.lifeos.backend.task.domain;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface TaskCompletionRepository {

    TaskCompletion save(TaskCompletion completion);

    List<TaskCompletion> saveAll(List<TaskCompletion> completions);

    Optional<TaskCompletion> findByTaskIdAndCompletionDate(
            UUID taskId,
            LocalDate completionDate
    );

    List<TaskCompletion> findByUserIdAndCompletionDate(
            UUID userId,
            LocalDate completionDate
    );

    void delete(TaskCompletion completion);
}