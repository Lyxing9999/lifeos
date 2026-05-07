package com.lifeos.backend.task.domain;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface TaskTagRepository {

    List<TaskTag> findByTaskId(UUID taskId);

    Optional<TaskTag> findByTaskIdAndName(UUID taskId, String name);

    void deleteByTaskId(UUID taskId);
}