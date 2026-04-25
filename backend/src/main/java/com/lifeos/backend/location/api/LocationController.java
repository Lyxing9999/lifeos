package com.lifeos.backend.location.api;

import com.lifeos.backend.common.response.ApiResponse;
import com.lifeos.backend.location.api.request.LocationBatchRequest;
import com.lifeos.backend.location.api.response.LocationBatchIngestResponse;
import com.lifeos.backend.location.api.response.LocationLogResponse;
import com.lifeos.backend.location.application.LocationBatchIngestionService;
import com.lifeos.backend.location.application.LocationLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/location")
@RequiredArgsConstructor
public class LocationController {

    private final LocationBatchIngestionService batchIngestionService;
    private final LocationLogService locationLogService;

    @PostMapping("/batch")
    public ApiResponse<LocationBatchIngestResponse> uploadBatch(@RequestBody LocationBatchRequest request) {
        return ApiResponse.success(
                batchIngestionService.ingest(request),
                "Location batch processed"
        );
    }

    @GetMapping("/user/{userId}/day")
    public ApiResponse<List<LocationLogResponse>> getByDay(
            @PathVariable UUID userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        return ApiResponse.success(locationLogService.getByUserIdAndDay(userId, date));
    }
}