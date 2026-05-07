package com.lifeos.backend.schedule.api.response;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class ScheduleCountSummaryResponse {
    private int total;
    private int active;
    private int inactive;
    private int history;
}