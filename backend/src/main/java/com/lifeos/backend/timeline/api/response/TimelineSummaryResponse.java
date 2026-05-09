package com.lifeos.backend.timeline.api.response;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class TimelineSummaryResponse {

    private Integer totalEntries;

    private Long totalTaskEntries;
    private Long completedTasks;
    private Long missedTasks;
    private Long skippedTasks;

    private Long totalScheduleEntries;
    private Long expiredScheduleBlocks;
    private Long cancelledScheduleBlocks;

    private Long totalStayEntries;
    private Long totalLocationEntries;
    private Long totalFinancialEntries;

    private Long totalVisibleSpanMinutes;
}