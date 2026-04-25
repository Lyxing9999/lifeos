package com.lifeos.backend.schedule.api;

import com.lifeos.backend.common.response.ApiResponse;
import com.lifeos.backend.schedule.api.request.CreateScheduleBlockRequest;
import com.lifeos.backend.schedule.api.request.UpdateScheduleBlockRequest;
import com.lifeos.backend.schedule.api.response.ScheduleBlockResponse;
import com.lifeos.backend.schedule.api.response.ScheduleOccurrenceResponse;
import com.lifeos.backend.schedule.application.ScheduleService;
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
public class ScheduleBlockController {

    private final ScheduleService scheduleService;

    @PostMapping
    public ApiResponse<ScheduleBlockResponse> create(@Valid @RequestBody CreateScheduleBlockRequest request) {
        return ApiResponse.success(scheduleService.create(request), "Schedule block created");
    }

    @PatchMapping("/{scheduleBlockId}")
    public ApiResponse<ScheduleBlockResponse> update(
            @PathVariable UUID scheduleBlockId,
            @RequestBody UpdateScheduleBlockRequest request
    ) {
        return ApiResponse.success(scheduleService.update(scheduleBlockId, request), "Schedule block updated");
    }

    @GetMapping("/user/{userId}")
    public ApiResponse<List<ScheduleBlockResponse>> getByUser(@PathVariable UUID userId) {
        return ApiResponse.success(scheduleService.getByUser(userId));
    }

    @GetMapping("/user/{userId}/day")
    public ApiResponse<List<ScheduleOccurrenceResponse>> getOccurrencesByDay(
            @PathVariable UUID userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        return ApiResponse.success(scheduleService.getOccurrencesByUserIdAndDay(userId, date));
    }

    @PostMapping("/{scheduleBlockId}/deactivate")
    public ApiResponse<Void> deactivate(@PathVariable UUID scheduleBlockId) {
        scheduleService.deactivate(scheduleBlockId);
        return ApiResponse.success(null, "Schedule block deactivated");
    }

    @DeleteMapping("/{scheduleBlockId}")
    public ApiResponse<Void> delete(@PathVariable UUID scheduleBlockId) {
        scheduleService.delete(scheduleBlockId);
        return ApiResponse.success(null, "Schedule block deleted");
    }
}