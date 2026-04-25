package com.lifeos.backend.task.api;

import com.lifeos.backend.common.response.ApiResponse;
import com.lifeos.backend.task.api.response.TaskOverviewBffResponse;
import com.lifeos.backend.task.application.TaskBffService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/task-bff")
@RequiredArgsConstructor
public class TaskBffController {

    private final TaskBffService taskBffService;

    @GetMapping("/{userId}/overview")
    public ApiResponse<TaskOverviewBffResponse> getOverview(
            @PathVariable UUID userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        return ApiResponse.success(taskBffService.getOverview(userId, date));
    }
}