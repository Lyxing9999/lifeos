package com.lifeos.backend.task.domain;

import java.util.List;
import java.util.UUID;

public interface TaskTagRepository {
    List<TaskTag> findByTaskId(UUID taskId);
}