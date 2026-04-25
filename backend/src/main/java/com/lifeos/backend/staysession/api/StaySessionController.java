package com.lifeos.backend.staysession.api;

import com.lifeos.backend.common.response.ApiResponse;
import com.lifeos.backend.staysession.api.response.StaySessionResponse;
import com.lifeos.backend.staysession.application.StaySessionRebuildService;
import com.lifeos.backend.staysession.application.StaySessionService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/stay-sessions")
@RequiredArgsConstructor
public class StaySessionController {

    private final StaySessionService staySessionService;
    private final StaySessionRebuildService rebuildService;

    @GetMapping("/user/{userId}/day")
    public ApiResponse<List<StaySessionResponse>> getByDay(
            @PathVariable UUID userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        return ApiResponse.success(
                staySessionService.getByUserIdAndDay(userId, date)
        );
    }

    @PostMapping("/rebuild/{userId}")
    public ApiResponse<String> rebuildDay(
            @PathVariable UUID userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        int created = rebuildService.rebuildDay(userId, date);
        return ApiResponse.success("Rebuilt " + created + " stay sessions");
    }

    @DeleteMapping("/user/{userId}/day")
    public ApiResponse<Void> deleteDay(
            @PathVariable UUID userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        rebuildService.deleteDay(userId, date);
        return ApiResponse.success(null, "Stay sessions deleted for day");
    }
}