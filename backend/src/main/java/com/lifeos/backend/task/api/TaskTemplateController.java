package com.lifeos.backend.task.api;

import com.lifeos.backend.task.api.request.CreateTaskTemplateRequest;
import com.lifeos.backend.task.api.request.LifecycleReasonRequest;
import com.lifeos.backend.task.api.request.UpdateTaskTemplateRequest;
import com.lifeos.backend.task.api.response.TaskTemplateResponse;
import com.lifeos.backend.task.application.command.TaskTemplateCommandService;
import com.lifeos.backend.task.application.query.TaskTemplateQueryService;
import com.lifeos.backend.task.domain.entity.TaskTemplate;
import com.lifeos.backend.task.infrastructure.mapper.TaskTemplateMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/task-templates")
@RequiredArgsConstructor
public class TaskTemplateController {

    private final TaskTemplateCommandService commandService;
    private final TaskTemplateQueryService queryService;
    private final TaskTemplateMapper mapper;

    @PostMapping
    public TaskTemplateResponse create(
            @RequestBody CreateTaskTemplateRequest request
    ) {
        TaskTemplateCommandService.TaskTemplateCommandResult result =
                commandService.create(
                        new TaskTemplateCommandService.CreateTaskTemplateCommand(
                                request.getUserId(),
                                request.getTitle(),
                                request.getDescription(),
                                request.getPriority(),
                                request.getCategory(),

                                request.getRecurrenceType(),
                                request.getRecurrenceStartDate(),
                                request.getRecurrenceEndDate(),
                                request.getRecurrenceDaysOfWeek(),

                                request.getDefaultDueTime(),
                                request.getDefaultDurationMinutes(),
                                request.getLinkedScheduleBlockId(),

                                request.getOverduePolicy(),
                                request.getRolloverPolicy(),
                                request.getMissedPolicy()
                        )
                );

        return mapper.toResponse(result.template());
    }

    @PatchMapping("/{templateId}")
    public TaskTemplateResponse update(
            @PathVariable UUID templateId,
            @RequestBody UpdateTaskTemplateRequest request
    ) {
        TaskTemplateCommandService.TaskTemplateCommandResult result =
                commandService.update(
                        request.getUserId(),
                        templateId,
                        new TaskTemplateCommandService.UpdateTaskTemplateCommand(
                                request.getTitle(),
                                request.getDescription(),
                                request.getPriority(),
                                request.getCategory(),

                                request.getRecurrenceType(),
                                request.getRecurrenceStartDate(),
                                request.getRecurrenceEndDate(),
                                Boolean.TRUE.equals(request.getClearRecurrenceEndDate()),
                                request.getRecurrenceDaysOfWeek(),

                                request.getDefaultDueTime(),
                                Boolean.TRUE.equals(request.getClearDefaultDueTime()),
                                request.getDefaultDurationMinutes(),
                                Boolean.TRUE.equals(request.getClearDefaultDurationMinutes()),
                                request.getLinkedScheduleBlockId(),
                                Boolean.TRUE.equals(request.getClearLinkedScheduleBlockId()),

                                request.getOverduePolicy(),
                                request.getRolloverPolicy(),
                                request.getMissedPolicy()
                        )
                );

        return mapper.toResponse(result.template());
    }

    @GetMapping("/{templateId}")
    public TaskTemplateResponse getById(
            @PathVariable UUID templateId,
            @RequestParam UUID userId
    ) {
        return mapper.toResponse(
                queryService.getByIdForUser(userId, templateId)
        );
    }

    @GetMapping
    public List<TaskTemplateResponse> getTemplates(
            @RequestParam UUID userId,
            @RequestParam(defaultValue = "ALL") String view
    ) {
        List<TaskTemplate> templates = switch (view.trim().toUpperCase()) {
            case "ACTIVE" -> queryService.getActiveForUser(userId);
            case "PAUSED" -> queryService.getPausedForUser(userId);
            case "ARCHIVED" -> queryService.getArchivedForUser(userId);
            case "RECURRING" -> queryService.getRecurringForUser(userId);
            case "ACTIVE_RECURRING" -> queryService.getActiveRecurringForUser(userId);
            default -> queryService.getAllForUser(userId);
        };

        return templates.stream()
                .map(mapper::toResponse)
                .toList();
    }

    @PostMapping("/{templateId}/pause")
    public TaskTemplateResponse pause(
            @PathVariable UUID templateId,
            @RequestBody LifecycleReasonRequest request
    ) {
        return mapper.toResponse(
                commandService.pause(
                        request.getUserId(),
                        templateId,
                        request.getReason()
                )
        );
    }

    @PostMapping("/{templateId}/resume")
    public TaskTemplateResponse resume(
            @PathVariable UUID templateId,
            @RequestBody LifecycleReasonRequest request
    ) {
        return mapper.toResponse(
                commandService.resume(
                        request.getUserId(),
                        templateId,
                        request.getReason()
                )
        );
    }

    @PostMapping("/{templateId}/archive")
    public TaskTemplateResponse archive(
            @PathVariable UUID templateId,
            @RequestBody LifecycleReasonRequest request
    ) {
        return mapper.toResponse(
                commandService.archive(
                        request.getUserId(),
                        templateId,
                        request.getReason()
                )
        );
    }

    @PostMapping("/{templateId}/restore")
    public TaskTemplateResponse restore(
            @PathVariable UUID templateId,
            @RequestBody LifecycleReasonRequest request
    ) {
        return mapper.toResponse(
                commandService.restore(
                        request.getUserId(),
                        templateId,
                        request.getReason()
                )
        );
    }

    @DeleteMapping("/{templateId}")
    public void delete(
            @PathVariable UUID templateId,
            @RequestParam UUID userId
    ) {
        commandService.delete(userId, templateId);
    }
}