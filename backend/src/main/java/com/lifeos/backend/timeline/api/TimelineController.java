package com.lifeos.backend.timeline.api;

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

    @GetMapping("/user/{userId}/day")
    @Operation(summary = "Get full timeline data for a user and day")
    public ApiResponse<TimelineDayResponse> getDay(
            @PathVariable UUID userId,
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        return ApiResponse.success(timelineService.getDay(userId, date));
    }
}