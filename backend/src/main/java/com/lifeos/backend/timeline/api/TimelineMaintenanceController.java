package com.lifeos.backend.timeline.api;

import com.lifeos.backend.common.response.ApiResponse;
import com.lifeos.backend.timeline.api.request.RebuildTimelineRequest;
import com.lifeos.backend.timeline.application.TimelineRebuildService;
import com.lifeos.backend.timeline.application.TimelineRebuildService.TimelineRebuildResult;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/timeline/maintenance")
@RequiredArgsConstructor
public class TimelineMaintenanceController {

    private final TimelineRebuildService timelineRebuildService;

    @PostMapping("/rebuild")
    public ApiResponse<TimelineRebuildResult> rebuild(
            @RequestBody RebuildTimelineRequest request
    ) {
        TimelineRebuildResult result = timelineRebuildService.rebuild(
                request.getUserId(),
                request.getStartDate(),
                request.getEndDate(),
                Boolean.TRUE.equals(request.getIncludeTasks()),
                Boolean.TRUE.equals(request.getIncludeSchedule())
        );

        return ApiResponse.success(result);
    }
}