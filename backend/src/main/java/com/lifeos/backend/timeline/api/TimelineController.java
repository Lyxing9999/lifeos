package com.lifeos.backend.timeline.api;

import com.lifeos.backend.auth.application.CurrentUserService;
import com.lifeos.backend.common.response.ApiResponse;
import com.lifeos.backend.timeline.application.TimelineService;
import com.lifeos.backend.timeline.dto.TimelineDayResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/timeline")
@RequiredArgsConstructor
@Tag(name = "Timeline", description = "Aggregated timeline APIs")
public class TimelineController {

    private final TimelineService timelineService;
    private final CurrentUserService currentUserService;

    @GetMapping("/me/day")
    @Operation(summary = "Get full timeline data for authenticated user and day")
    public ApiResponse<TimelineDayResponse> getMyDay(
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        UUID userId = currentUserService.getUserId();
        return ApiResponse.success(timelineService.getDay(userId, date));
    }

    /**
     * Deprecated compatibility endpoint.
     * Kept temporarily while frontend/tests migrate to /me.
     * The path userId is intentionally ignored.
     */
    @Deprecated
    @GetMapping("/user/{userId}/day")
    @Operation(summary = "Deprecated: use /api/v1/timeline/me/day")
    public ApiResponse<TimelineDayResponse> getDayDeprecated(
            @PathVariable UUID userId,
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        UUID authenticatedUserId = currentUserService.getUserId();
        return ApiResponse.success(timelineService.getDay(authenticatedUserId, date));
    }
}