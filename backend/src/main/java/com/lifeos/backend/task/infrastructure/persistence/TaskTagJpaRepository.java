package com.lifeos.backend.task.infrastructure.persistence;

import com.lifeos.backend.task.domain.TaskTag;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface TaskTagJpaRepository extends JpaRepository<TaskTag, UUID> {

    List<TaskTag> findByTaskId(UUID taskId);

    Optional<TaskTag> findByTaskIdAndName(UUID taskId, String name);

    void deleteByTaskId(UUID taskId);
}