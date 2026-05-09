package com.lifeos.backend.today.api.response;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class TodayCountsResponse {

    private Integer openTasks;
    private Integer overdueTasks;
    private Integer dueTodayTasks;
    private Integer inboxTasks;
    private Integer completedTodayTasks;

    private Integer visibleScheduleBlocks;
    private Integer activeScheduleBlocks;
    private Integer upcomingScheduleBlocks;
    private Integer expiredScheduleBlocks;

    private Integer timelineEntries;
}