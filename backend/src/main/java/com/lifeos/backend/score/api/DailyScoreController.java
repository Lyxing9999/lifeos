package com.lifeos.backend.score.api;

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

    @PostMapping("/user/{userId}/generate")
    public ApiResponse<DailyScoreResponse> generate(
            @PathVariable UUID userId,
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        return ApiResponse.success(
                dailyScoreService.generate(userId, date),
                "Daily score generated"
        );
    }

    @GetMapping("/user/{userId}/day")
    public ApiResponse<DailyScoreResponse> get(
            @PathVariable UUID userId,
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        return ApiResponse.success(dailyScoreService.get(userId, date));
    }

    @DeleteMapping("/user/{userId}/day")
    public ApiResponse<Void> delete(
            @PathVariable UUID userId,
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        dailyScoreService.delete(userId, date);
        return ApiResponse.success(null, "Daily score deleted");
    }
}