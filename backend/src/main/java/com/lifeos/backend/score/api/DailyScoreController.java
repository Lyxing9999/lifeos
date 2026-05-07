package com.lifeos.backend.score.api;

import com.lifeos.backend.auth.application.CurrentUserService;
import com.lifeos.backend.common.response.ApiResponse;
import com.lifeos.backend.score.api.response.DailyScoreResponse;
import com.lifeos.backend.score.application.DailyScoreService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/score")
@RequiredArgsConstructor
public class DailyScoreController {

    private final DailyScoreService dailyScoreService;
    private final CurrentUserService currentUserService;

    @PostMapping("/me/generate")
    public ApiResponse<DailyScoreResponse> generateMine(
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        UUID userId = currentUserService.getUserId();

        return ApiResponse.success(
                dailyScoreService.generate(userId, date),
                "Daily score generated"
        );
    }

    @GetMapping("/me/day")
    public ApiResponse<DailyScoreResponse> getMine(
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        UUID userId = currentUserService.getUserId();
        return ApiResponse.success(dailyScoreService.get(userId, date));
    }

    @DeleteMapping("/me/day")
    public ApiResponse<Void> deleteMine(
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        UUID userId = currentUserService.getUserId();

        dailyScoreService.delete(userId, date);

        return ApiResponse.success(null, "Daily score deleted");
    }

    /**
     * Deprecated compatibility endpoint.
     * Kept temporarily while frontend/tests migrate to /me.
     * The path userId is intentionally ignored.
     */
    @Deprecated
    @PostMapping("/user/{userId}/generate")
    public ApiResponse<DailyScoreResponse> generateDeprecated(
            @PathVariable UUID userId,
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        UUID authenticatedUserId = currentUserService.getUserId();

        return ApiResponse.success(
                dailyScoreService.generate(authenticatedUserId, date),
                "Daily score generated"
        );
    }

    /**
     * Deprecated compatibility endpoint.
     * Kept temporarily while frontend/tests migrate to /me.
     * The path userId is intentionally ignored.
     */
    @Deprecated
    @GetMapping("/user/{userId}/day")
    public ApiResponse<DailyScoreResponse> getDeprecated(
            @PathVariable UUID userId,
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        UUID authenticatedUserId = currentUserService.getUserId();
        return ApiResponse.success(dailyScoreService.get(authenticatedUserId, date));
    }

    /**
     * Deprecated compatibility endpoint.
     * Kept temporarily while frontend/tests migrate to /me.
     * The path userId is intentionally ignored.
     */
    @Deprecated
    @DeleteMapping("/user/{userId}/day")
    public ApiResponse<Void> deleteDeprecated(
            @PathVariable UUID userId,
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        UUID authenticatedUserId = currentUserService.getUserId();

        dailyScoreService.delete(authenticatedUserId, date);

        return ApiResponse.success(null, "Daily score deleted");
    }
}