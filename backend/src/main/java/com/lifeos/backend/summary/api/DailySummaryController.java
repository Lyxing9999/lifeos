package com.lifeos.backend.summary.api;

import com.lifeos.backend.common.response.ApiResponse;
import com.lifeos.backend.summary.api.response.DailySummaryResponse;
import com.lifeos.backend.summary.application.DailySummaryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/summaries/daily")
@RequiredArgsConstructor
@Tag(name = "Daily Summaries", description = "Daily summary APIs")
public class DailySummaryController {

    private final DailySummaryService dailySummaryService;

    @PostMapping("/generate/{userId}")
    @Operation(summary = "Generate daily summary")
    public ApiResponse<DailySummaryResponse> generate(
            @PathVariable UUID userId,
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        return ApiResponse.success(dailySummaryService.generate(userId, date), "Daily summary generated");
    }

    @GetMapping("/{userId}")
    @Operation(summary = "Get daily summary")
    public ApiResponse<DailySummaryResponse> get(
            @PathVariable UUID userId,
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        return ApiResponse.success(dailySummaryService.get(userId, date));
    }

    @DeleteMapping("/{userId}")
    @Operation(summary = "Delete daily summary")
    public ApiResponse<Void> delete(
            @PathVariable UUID userId,
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        dailySummaryService.delete(userId, date);
        return ApiResponse.success(null, "Daily summary deleted");
    }
}