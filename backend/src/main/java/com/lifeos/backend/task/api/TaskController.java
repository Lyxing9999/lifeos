package com.lifeos.backend.task.api;

import com.lifeos.backend.common.response.ApiResponse;
import com.lifeos.backend.task.api.request.CreateTaskRequest;
import com.lifeos.backend.task.api.request.UpdateTaskRequest;
import com.lifeos.backend.task.api.response.TaskOverviewBffResponse;
import com.lifeos.backend.task.api.response.TaskResponse;
import com.lifeos.backend.task.api.response.TaskSectionResponse;
import com.lifeos.backend.task.application.TaskBffService;
import com.lifeos.backend.task.application.TaskService;
import com.lifeos.backend.task.domain.TaskFilterType;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/tasks")
@RequiredArgsConstructor
public class TaskController {

    private final TaskService taskService;
    private final TaskBffService taskBffService;

    @PostMapping
    public ApiResponse<TaskResponse> create(@Valid @RequestBody CreateTaskRequest request) {
        return ApiResponse.success(taskService.create(request), "Task created");
    }

    @PatchMapping("/{taskId}")
    public ApiResponse<TaskResponse> update(
            @PathVariable UUID taskId,
            @RequestBody UpdateTaskRequest request
    ) {
        return ApiResponse.success(taskService.update(taskId, request), "Task updated");
    }

    @PostMapping("/{taskId}/complete")
    public ApiResponse<TaskResponse> complete(@PathVariable UUID taskId) {
        return ApiResponse.success(taskService.complete(taskId), "Task completed");
    }

    @GetMapping("/user/{userId}")
    public ApiResponse<List<TaskResponse>> getByUser(
            @PathVariable UUID userId,
            @RequestParam(defaultValue = "ACTIVE") TaskFilterType filter
    ) {
        return ApiResponse.success(taskService.getByUserId(userId, filter));
    }

    @GetMapping("/user/{userId}/day")
    public ApiResponse<List<TaskResponse>> getRelevantByDay(
            @PathVariable UUID userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam(defaultValue = "ALL") TaskFilterType filter
    ) {
        return ApiResponse.success(taskService.getRelevantTasksByUserAndDay(userId, date, filter));
    }

    @GetMapping("/user/{userId}/sections")
    public ApiResponse<TaskSectionResponse> getSectionsForDay(
            @PathVariable UUID userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam(defaultValue = "ALL") TaskFilterType filter
    ) {
        return ApiResponse.success(taskService.getSectionsForDay(userId, date, filter));
    }

    @GetMapping("/user/{userId}/overview")
    public ApiResponse<TaskOverviewBffResponse> getOverview(
            @PathVariable UUID userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        return ApiResponse.success(taskBffService.getOverview(userId, date));
    }

    @DeleteMapping("/{taskId}")
    public ApiResponse<Void> delete(@PathVariable UUID taskId) {
        taskService.delete(taskId);
        return ApiResponse.success(null, "Task deleted");
    }
}