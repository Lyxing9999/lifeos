package com.lifeos.backend.schedule.api;

import com.lifeos.backend.auth.application.CurrentUserService;
import com.lifeos.backend.common.response.ApiResponse;
import com.lifeos.backend.schedule.api.request.CreateScheduleBlockRequest;
import com.lifeos.backend.schedule.api.request.UpdateScheduleBlockRequest;
import com.lifeos.backend.schedule.api.response.ScheduleBlockResponse;
import com.lifeos.backend.schedule.api.response.ScheduleSelectOptionResponse;
import com.lifeos.backend.schedule.api.response.ScheduleSurfaceBffResponse;
import com.lifeos.backend.schedule.application.ScheduleBffService;
import com.lifeos.backend.schedule.application.ScheduleCommandService;
import com.lifeos.backend.schedule.application.ScheduleQueryService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/schedules")
@RequiredArgsConstructor
public class ScheduleController {

    private final ScheduleQueryService queryService;
    private final ScheduleBffService bffService;
    private final ScheduleCommandService commandService;
    private final CurrentUserService currentUserService;

    @GetMapping("/me/surfaces")
    public ApiResponse<ScheduleSurfaceBffResponse> getSurfaces(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        UUID userId = currentUserService.getUserId();
        return ApiResponse.success(bffService.getSurfaces(userId, date));
    }

    @GetMapping("/me/select-options")
    public ApiResponse<List<ScheduleSelectOptionResponse>> getMySelectOptions(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        UUID userId = currentUserService.getUserId();
        return ApiResponse.success(queryService.getActiveSelectOptions(userId, date));
    }

    @GetMapping("/{scheduleBlockId}")
    public ApiResponse<ScheduleBlockResponse> getById(
            @PathVariable UUID scheduleBlockId
    ) {
        UUID userId = currentUserService.getUserId();
        return ApiResponse.success(queryService.getByIdForUser(userId, scheduleBlockId));
    }

    @PostMapping
    public ApiResponse<ScheduleBlockResponse> create(
            @Valid @RequestBody CreateScheduleBlockRequest request
    ) {
        UUID userId = currentUserService.getUserId();
        return ApiResponse.success(commandService.create(userId, request), "Schedule block created");
    }

    @PatchMapping("/{scheduleBlockId}")
    public ApiResponse<ScheduleBlockResponse> update(
            @PathVariable UUID scheduleBlockId,
            @RequestBody UpdateScheduleBlockRequest request
    ) {
        UUID userId = currentUserService.getUserId();
        return ApiResponse.success(commandService.update(userId, scheduleBlockId, request), "Schedule block updated");
    }

    @PostMapping("/{scheduleBlockId}/deactivate")
    public ApiResponse<ScheduleBlockResponse> deactivate(
            @PathVariable UUID scheduleBlockId
    ) {
        UUID userId = currentUserService.getUserId();
        return ApiResponse.success(commandService.deactivate(userId, scheduleBlockId), "Schedule block deactivated");
    }

    @PostMapping("/{scheduleBlockId}/activate")
    public ApiResponse<ScheduleBlockResponse> activate(
            @PathVariable UUID scheduleBlockId
    ) {
        UUID userId = currentUserService.getUserId();
        return ApiResponse.success(commandService.activate(userId, scheduleBlockId), "Schedule block activated");
    }

    @DeleteMapping("/{scheduleBlockId}")
    public ApiResponse<Void> delete(
            @PathVariable UUID scheduleBlockId
    ) {
        UUID userId = currentUserService.getUserId();
        commandService.delete(userId, scheduleBlockId);
        return ApiResponse.success(null, "Schedule block deleted");
    }
}