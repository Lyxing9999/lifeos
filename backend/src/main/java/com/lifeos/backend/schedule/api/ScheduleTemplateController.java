package com.lifeos.backend.schedule.api;

import com.lifeos.backend.schedule.api.request.CreateScheduleTemplateRequest;
import com.lifeos.backend.schedule.api.request.ScheduleReasonRequest;
import com.lifeos.backend.schedule.api.request.UpdateScheduleTemplateRequest;
import com.lifeos.backend.schedule.api.response.ScheduleTemplateResponse;
import com.lifeos.backend.schedule.application.command.ScheduleTemplateCommandService;
import com.lifeos.backend.schedule.application.query.ScheduleTemplateQueryService;
import com.lifeos.backend.schedule.domain.entity.ScheduleTemplate;
import com.lifeos.backend.schedule.infrastructure.mapper.ScheduleTemplateMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/schedule-templates")
@RequiredArgsConstructor
public class ScheduleTemplateController {

    private final ScheduleTemplateCommandService commandService;
    private final ScheduleTemplateQueryService queryService;
    private final ScheduleTemplateMapper mapper;

    @PostMapping
    public ScheduleTemplateResponse create(
            @RequestBody CreateScheduleTemplateRequest request
    ) {
        ScheduleTemplateCommandService.ScheduleTemplateCommandResult result =
                commandService.create(
                        new ScheduleTemplateCommandService.CreateScheduleTemplateCommand(
                                request.getUserId(),
                                request.getTitle(),
                                request.getDescription(),
                                request.getType(),

                                request.getStartTime(),
                                request.getEndTime(),

                                request.getRecurrenceType(),
                                request.getRecurrenceStartDate(),
                                request.getRecurrenceEndDate(),
                                request.getRecurrenceDaysOfWeek(),

                                request.getColorKey(),
                                request.getExternalCalendarId()
                        )
                );

        return mapper.toResponse(result.template());
    }

    @PatchMapping("/{templateId}")
    public ScheduleTemplateResponse update(
            @PathVariable UUID templateId,
            @RequestBody UpdateScheduleTemplateRequest request
    ) {
        ScheduleTemplateCommandService.ScheduleTemplateCommandResult result =
                commandService.update(
                        request.getUserId(),
                        templateId,
                        new ScheduleTemplateCommandService.UpdateScheduleTemplateCommand(
                                request.getTitle(),
                                request.getDescription(),
                                request.getType(),

                                request.getStartTime(),
                                request.getEndTime(),

                                request.getRecurrenceType(),
                                request.getRecurrenceStartDate(),
                                request.getRecurrenceEndDate(),
                                Boolean.TRUE.equals(request.getClearRecurrenceEndDate()),
                                request.getRecurrenceDaysOfWeek(),

                                request.getColorKey(),
                                Boolean.TRUE.equals(request.getClearColorKey()),

                                request.getExternalCalendarId(),
                                Boolean.TRUE.equals(request.getClearExternalCalendarId())
                        )
                );

        return mapper.toResponse(result.template());
    }

    @GetMapping("/{templateId}")
    public ScheduleTemplateResponse getById(
            @PathVariable UUID templateId,
            @RequestParam UUID userId
    ) {
        return mapper.toResponse(
                queryService.getByIdForUser(userId, templateId)
        );
    }

    @GetMapping
    public List<ScheduleTemplateResponse> getTemplates(
            @RequestParam UUID userId,
            @RequestParam(defaultValue = "ALL") String view
    ) {
        List<ScheduleTemplate> templates = switch (view.trim().toUpperCase()) {
            case "ACTIVE" -> queryService.getActiveForUser(userId);
            case "PAUSED" -> queryService.getPausedForUser(userId);
            case "ARCHIVED" -> queryService.getArchivedForUser(userId);
            case "ACTIVE_AND_PAUSED" -> queryService.getActiveAndPausedForUser(userId);
            case "RECURRING" -> queryService.getRecurringForUser(userId);
            case "ACTIVE_RECURRING" -> queryService.getActiveRecurringForUser(userId);
            case "ONE_TIME" -> queryService.getOneTimeForUser(userId);
            default -> queryService.getAllForUser(userId);
        };

        return templates.stream()
                .map(mapper::toResponse)
                .toList();
    }

    @PostMapping("/{templateId}/pause")
    public ScheduleTemplateResponse pause(
            @PathVariable UUID templateId,
            @RequestBody ScheduleReasonRequest request
    ) {
        return mapper.toResponse(
                commandService.pause(
                        request.getUserId(),
                        templateId
                )
        );
    }

    @PostMapping("/{templateId}/resume")
    public ScheduleTemplateResponse resume(
            @PathVariable UUID templateId,
            @RequestBody ScheduleReasonRequest request
    ) {
        return mapper.toResponse(
                commandService.resume(
                        request.getUserId(),
                        templateId
                )
        );
    }

    @PostMapping("/{templateId}/archive")
    public ScheduleTemplateResponse archive(
            @PathVariable UUID templateId,
            @RequestBody ScheduleReasonRequest request
    ) {
        return mapper.toResponse(
                commandService.archive(
                        request.getUserId(),
                        templateId
                )
        );
    }

    @PostMapping("/{templateId}/restore")
    public ScheduleTemplateResponse restore(
            @PathVariable UUID templateId,
            @RequestBody ScheduleReasonRequest request
    ) {
        return mapper.toResponse(
                commandService.restore(
                        request.getUserId(),
                        templateId
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