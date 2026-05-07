package com.lifeos.backend.today.api;

import com.lifeos.backend.auth.application.CurrentUserService;
import com.lifeos.backend.common.response.ApiResponse;
import com.lifeos.backend.today.application.TodayService;
import com.lifeos.backend.today.dto.TodayResponse;
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
@Tag(name = "Today", description = "Today aggregate API")
public class TodayController {

    private final TodayService todayService;
    private final CurrentUserService currentUserService;

    @GetMapping("/me")
    @Operation(summary = "Get complete today data for authenticated user")
    public ApiResponse<TodayResponse> getMine(
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        UUID userId = currentUserService.getUserId();
        return ApiResponse.success(todayService.get(userId, date));
    }

    @Deprecated
    @GetMapping("/{userId}")
    @Operation(summary = "Deprecated: use /api/v1/today/me")
    public ApiResponse<TodayResponse> getDeprecated(
            @PathVariable UUID userId,
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        UUID authenticatedUserId = currentUserService.getUserId();
        return ApiResponse.success(todayService.get(authenticatedUserId, date));
    }
}