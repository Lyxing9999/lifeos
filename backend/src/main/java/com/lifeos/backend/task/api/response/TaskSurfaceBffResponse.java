package com.lifeos.backend.task.api.response;

import com.lifeos.backend.task.domain.enums.TaskFilterType;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.util.List;

@Getter
@Builder
public class TaskSurfaceBffResponse {
    private LocalDate date;
    private TaskFilterType filter;

    /**
     * Final Flutter primary surfaces.
     */
    private List<TaskResponse> dueTasks;
    private List<TaskResponse> inboxTasks;
    private List<TaskResponse> doneTasks;

    /**
     * Secondary workspaces.
     */
    private List<TaskResponse> allTasks;
    private List<TaskResponse> pausedTasks;
    private List<TaskResponse> historyTasks;
    private List<TaskResponse> archivedTasks;

    /**
     * Backward-compatible aliases.
     */
    private List<TaskResponse> todayTasks;
    private List<TaskResponse> scheduleLinkedTasks;
    private List<TaskResponse> anytimeTasks;
    private List<TaskResponse> achievedTasks;

    private TaskCountSummaryResponse dueCounts;
    private TaskCountSummaryResponse inboxCounts;
    private TaskCountSummaryResponse doneCounts;
    private TaskCountSummaryResponse allCounts;
    private TaskCountSummaryResponse pausedCounts;
    private TaskCountSummaryResponse historyCounts;
    private TaskCountSummaryResponse archivedCounts;

    /**
     * Backward-compatible aliases.
     */
    private TaskCountSummaryResponse todayCounts;
    private TaskCountSummaryResponse scheduleLinkedCounts;
    private TaskCountSummaryResponse anytimeCounts;
    private TaskCountSummaryResponse achievedCounts;
}