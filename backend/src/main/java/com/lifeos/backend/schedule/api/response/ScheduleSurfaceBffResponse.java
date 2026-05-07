package com.lifeos.backend.schedule.api.response;

import lombok.Builder;
import lombok.Getter;
import java.time.LocalDate;
import java.util.List;

@Getter
@Builder
public class ScheduleSurfaceBffResponse {
    private LocalDate date;
    private List<ScheduleBlockResponse> activeBlocks;
    private List<ScheduleBlockResponse> inactiveBlocks;
    private ScheduleCountSummaryResponse counts;
    private List<ScheduleBlockResponse> historyBlocks;

}