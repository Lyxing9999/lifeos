package com.lifeos.backend.today.api;

import com.lifeos.backend.auth.application.CurrentUserService;
import com.lifeos.backend.common.response.ApiResponse;
import com.lifeos.backend.today.api.response.TodayWorkspaceResponse;
import com.lifeos.backend.today.application.TodayWorkspaceService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/today")
@RequiredArgsConstructor
@Tag(name = "Today", description = "Present focus workspace APIs")
public class TodayController {

    private final TodayWorkspaceService todayWorkspaceService;
    private final CurrentUserService currentUserService;

    @GetMapping("/me/workspace")
    @Operation(summary = "Get Today workspace for authenticated user")
    public ApiResponse<TodayWorkspaceResponse> getMyWorkspace(
            @RequestParam(value = "date", required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
            LocalDate date
    ) {
        UUID userId = currentUserService.getUserId();

        return ApiResponse.success(
                todayWorkspaceService.getWorkspace(userId, date)
        );
    }

    /**
     * Dogfooding/dev endpoint.
     * Keep if you still use manual userId during local development.
     */
    @GetMapping("/workspace")
    @Operation(summary = "Get Today workspace by userId")
    public ApiResponse<TodayWorkspaceResponse> getWorkspace(
            @RequestParam UUID userId,
            @RequestParam(value = "date", required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
            LocalDate date
    ) {
        return ApiResponse.success(
                todayWorkspaceService.getWorkspace(userId, date)
        );
    }

    /**
     * Backward compatible route.
     * Remove later after frontend migrates to /me/workspace.
     */
    @Deprecated
    @GetMapping("/me")
    @Operation(summary = "Deprecated: use /api/v1/today/me/workspace")
    public ApiResponse<TodayWorkspaceResponse> getMine(
            @RequestParam(value = "date", required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
            LocalDate date
    ) {
        UUID userId = currentUserService.getUserId();

        return ApiResponse.success(
                todayWorkspaceService.getWorkspace(userId, date)
        );
    }
}