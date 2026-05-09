package com.lifeos.backend.timeline.api;

import com.lifeos.backend.auth.application.CurrentUserService;
import com.lifeos.backend.common.response.ApiResponse;
import com.lifeos.backend.timeline.api.response.TimelineDayResponse;
import com.lifeos.backend.timeline.application.TimelineDayAssembler;
import com.lifeos.backend.timeline.application.TimelineDayAssembler.TimelineDayView;
import com.lifeos.backend.timeline.application.TimelineDayQueryService;
import com.lifeos.backend.timeline.application.TimelineDayQueryService.TimelineDayQueryResult;
import com.lifeos.backend.timeline.infrastructure.mapper.TimelineEntryMapper;
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
@Tag(name = "Timeline", description = "Past truth ledger APIs")
public class TimelineController {

    private final TimelineDayQueryService timelineDayQueryService;
    private final TimelineDayAssembler timelineDayAssembler;
    private final TimelineEntryMapper timelineEntryMapper;
    private final CurrentUserService currentUserService;

    @GetMapping("/me/day")
    @Operation(summary = "Get timeline ledger for authenticated user and day")
    public ApiResponse<TimelineDayResponse> getMyDay(
            @RequestParam("date")
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
            LocalDate date
    ) {
        UUID userId = currentUserService.getUserId();

        TimelineDayQueryResult queryResult =
                timelineDayQueryService.getDay(userId, date);

        TimelineDayView view =
                timelineDayAssembler.assemble(queryResult);

        return ApiResponse.success(
                timelineEntryMapper.toDayResponse(view)
        );
    }

    @GetMapping("/day")
    @Operation(summary = "Get timeline ledger for user and day")
    public ApiResponse<TimelineDayResponse> getDay(
            @RequestParam UUID userId,
            @RequestParam("date")
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
            LocalDate date
    ) {
        TimelineDayQueryResult queryResult =
                timelineDayQueryService.getDay(userId, date);

        TimelineDayView view =
                timelineDayAssembler.assemble(queryResult);

        return ApiResponse.success(
                timelineEntryMapper.toDayResponse(view)
        );
    }
}