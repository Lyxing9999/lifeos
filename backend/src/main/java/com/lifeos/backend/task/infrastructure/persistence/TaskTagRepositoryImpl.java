package com.lifeos.backend.task.infrastructure.persistence;

import com.lifeos.backend.task.domain.TaskTag;
import com.lifeos.backend.task.domain.TaskTagRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
public class TaskTagRepositoryImpl implements TaskTagRepository {

    private final TaskTagJpaRepository jpaRepository;

    @Override
    public List<TaskTag> findByTaskId(UUID taskId) {
        return jpaRepository.findByTaskId(taskId);
    }
}