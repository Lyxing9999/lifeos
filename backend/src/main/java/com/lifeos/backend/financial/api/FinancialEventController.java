package com.lifeos.backend.financial.api;

import com.lifeos.backend.common.response.ApiResponse;
import com.lifeos.backend.financial.api.response.FinancialEventResponse;
import com.lifeos.backend.financial.api.response.FinancialSummaryResponse;
import com.lifeos.backend.financial.application.FinancialEventService;
import com.lifeos.backend.financial.application.FinancialSummaryService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/financial-events")
@RequiredArgsConstructor
public class FinancialEventController {

    private final FinancialEventService financialEventService;
    private final FinancialSummaryService financialSummaryService;

    @GetMapping("/user/{userId}/day")
    public ApiResponse<List<FinancialEventResponse>> getByDay(
            @PathVariable UUID userId,
            @RequestParam LocalDate date,
            @RequestParam String timezone
    ) {
        return ApiResponse.success(financialEventService.getByUserIdAndDay(userId, date, timezone));
    }

    @GetMapping("/user/{userId}/range")
    public ApiResponse<List<FinancialEventResponse>> getByRange(
            @PathVariable UUID userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam String timezone
    ) {
        return ApiResponse.success(
                financialEventService.getByUserIdAndRange(userId, startDate, endDate, timezone)
        );
    }

    @GetMapping("/user/{userId}/day-summary")
    public ApiResponse<FinancialSummaryResponse> getDaySummary(
            @PathVariable UUID userId,
            @RequestParam LocalDate date,
            @RequestParam String timezone
    ) {
        List<FinancialEventResponse> events =
                financialEventService.getByUserIdAndDay(userId, date, timezone);

        return ApiResponse.success(financialSummaryService.buildSummary(events));
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> delete(@PathVariable UUID id) {
        financialEventService.delete(id);
        return ApiResponse.success(null, "Deleted");
    }
}