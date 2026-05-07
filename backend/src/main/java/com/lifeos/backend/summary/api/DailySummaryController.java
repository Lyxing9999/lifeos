package com.lifeos.backend.summary.api;

import com.lifeos.backend.auth.application.CurrentUserService;
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
    private final CurrentUserService currentUserService;

    @PostMapping("/me/generate")
    @Operation(summary = "Generate daily summary for authenticated user")
    public ApiResponse<DailySummaryResponse> generateMine(
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        UUID userId = currentUserService.getUserId();

        return ApiResponse.success(
                dailySummaryService.generate(userId, date),
                "Daily summary generated"
        );
    }

    @GetMapping("/me")
    @Operation(summary = "Get daily summary for authenticated user")
    public ApiResponse<DailySummaryResponse> getMine(
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        UUID userId = currentUserService.getUserId();

        return ApiResponse.success(dailySummaryService.get(userId, date));
    }

    @DeleteMapping("/me")
    @Operation(summary = "Delete daily summary for authenticated user")
    public ApiResponse<Void> deleteMine(
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        UUID userId = currentUserService.getUserId();

        dailySummaryService.delete(userId, date);

        return ApiResponse.success(null, "Daily summary deleted");
    }

    /**
     * Deprecated compatibility endpoint.
     * Kept temporarily while frontend/tests migrate to /me.
     * The path userId is intentionally ignored.
     */
    @Deprecated
    @PostMapping("/generate/{userId}")
    @Operation(
            summary = "Deprecated: use /api/v1/summaries/daily/me/generate",
            deprecated = true
    )
    public ApiResponse<DailySummaryResponse> generateDeprecated(
            @PathVariable UUID userId,
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        UUID authenticatedUserId = currentUserService.getUserId();

        return ApiResponse.success(
                dailySummaryService.generate(authenticatedUserId, date),
                "Daily summary generated"
        );
    }

    /**
     * Deprecated compatibility endpoint.
     * Kept temporarily while frontend/tests migrate to /me.
     * The path userId is intentionally ignored.
     */
    @Deprecated
    @GetMapping("/{userId}")
    @Operation(
            summary = "Deprecated: use /api/v1/summaries/daily/me",
            deprecated = true
    )
    public ApiResponse<DailySummaryResponse> getDeprecated(
            @PathVariable UUID userId,
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        UUID authenticatedUserId = currentUserService.getUserId();

        return ApiResponse.success(dailySummaryService.get(authenticatedUserId, date));
    }

    /**
     * Deprecated compatibility endpoint.
     * Kept temporarily while frontend/tests migrate to /me.
     * The path userId is intentionally ignored.
     */
    @Deprecated
    @DeleteMapping("/{userId}")
    @Operation(
            summary = "Deprecated: use /api/v1/summaries/daily/me",
            deprecated = true
    )
    public ApiResponse<Void> deleteDeprecated(
            @PathVariable UUID userId,
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        UUID authenticatedUserId = currentUserService.getUserId();

        dailySummaryService.delete(authenticatedUserId, date);

        return ApiResponse.success(null, "Daily summary deleted");
    }
}