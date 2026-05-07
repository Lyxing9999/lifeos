package com.lifeos.backend.task.infrastructure.persistence;

import com.lifeos.backend.task.domain.TaskTag;
import com.lifeos.backend.task.domain.TaskTagRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
public class TaskTagRepositoryImpl implements TaskTagRepository {

    private final TaskTagJpaRepository taskTagJpaRepository;

    @Override
    public List<TaskTag> findByTaskId(UUID taskId) {
        return taskTagJpaRepository.findByTaskId(taskId);
    }

    @Override
    public Optional<TaskTag> findByTaskIdAndName(UUID taskId, String name) {
        return taskTagJpaRepository.findByTaskIdAndName(taskId, name);
    }

    @Override
    public void deleteByTaskId(UUID taskId) {
        taskTagJpaRepository.deleteByTaskId(taskId);
    }
}