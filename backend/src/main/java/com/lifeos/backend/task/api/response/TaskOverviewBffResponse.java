package com.lifeos.backend.task.api.response;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.util.List;

@Getter
@Builder
public class TaskOverviewBffResponse {
    private LocalDate date;

    private TaskResponse currentTask;
    private TaskResponse currentUrgentTask;
    private TaskResponse currentDailyTask;
    private TaskResponse currentProgressTask;

    private TaskSectionResponse todaySections;
    private TaskSectionResponse last3DaySections;
    private TaskSectionResponse last7DaySections;
    private TaskSectionResponse last30DaySections;

    private TaskCountSummaryResponse todayCounts;
    private TaskCountSummaryResponse last3DayCounts;
    private TaskCountSummaryResponse last7DayCounts;
    private TaskCountSummaryResponse last30DayCounts;

    private List<TaskResponse> recentCompletedTasks;
}