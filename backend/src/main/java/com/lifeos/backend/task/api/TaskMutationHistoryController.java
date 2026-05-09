package com.lifeos.backend.task.api;

import com.lifeos.backend.task.api.response.TaskMutationHistoryResponse;
import com.lifeos.backend.task.application.query.TaskMutationHistoryQueryService;
import com.lifeos.backend.task.domain.enums.MutationType;
import com.lifeos.backend.task.infrastructure.mapper.TaskMutationHistoryMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/task-mutations")
@RequiredArgsConstructor
public class TaskMutationHistoryController {

    private final TaskMutationHistoryQueryService queryService;
    private final TaskMutationHistoryMapper mapper;

    /**
     * Get all task mutation history for a user.
     *
     * Example:
     * GET /api/v1/task-mutations?userId=...
     */
    @GetMapping
    public List<TaskMutationHistoryResponse> getByUser(
            @RequestParam UUID userId
    ) {
        return queryService.getByUser(userId)
                .stream()
                .map(mapper::toResponse)
                .toList();
    }

    /**
     * Get mutation history for one task template.
     *
     * Example:
     * GET /api/v1/task-mutations/template/{templateId}
     */
    @GetMapping("/template/{templateId}")
    public List<TaskMutationHistoryResponse> getByTemplate(
            @PathVariable UUID templateId
    ) {
        return queryService.getByTemplate(templateId)
                .stream()
                .map(mapper::toResponse)
                .toList();
    }

    /**
     * Get mutation history for one task instance.
     *
     * Example:
     * GET /api/v1/task-mutations/instance/{taskInstanceId}
     */
    @GetMapping("/instance/{taskInstanceId}")
    public List<TaskMutationHistoryResponse> getByInstance(
            @PathVariable UUID taskInstanceId
    ) {
        return queryService.getByInstance(taskInstanceId)
                .stream()
                .map(mapper::toResponse)
                .toList();
    }

    /**
     * Get mutation history for one user-local date.
     *
     * Example:
     * GET /api/v1/task-mutations/date?userId=...&date=2026-05-08
     */
    @GetMapping("/date")
    public List<TaskMutationHistoryResponse> getByUserAndDate(
            @RequestParam UUID userId,
            @RequestParam LocalDate date
    ) {
        return queryService.getByUserAndDate(userId, date)
                .stream()
                .map(mapper::toResponse)
                .toList();
    }

    /**
     * Get mutation history by mutation type.
     *
     * Example:
     * GET /api/v1/task-mutations/type?userId=...&mutationType=INSTANCE_COMPLETED
     */
    @GetMapping("/type")
    public List<TaskMutationHistoryResponse> getByUserAndMutationType(
            @RequestParam UUID userId,
            @RequestParam MutationType mutationType
    ) {
        return queryService.getByUserAndMutationType(userId, mutationType)
                .stream()
                .map(mapper::toResponse)
                .toList();
    }
}