package com.lifeos.backend.today.api.response;

import com.lifeos.backend.task.api.response.TaskInstanceResponse;
import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
public class TodayTaskSectionResponse {

    private List<TaskInstanceResponse> overdueTasks;
    private List<TaskInstanceResponse> dueTodayTasks;
    private List<TaskInstanceResponse> inProgressTasks;
    private List<TaskInstanceResponse> inboxTasks;
    private List<TaskInstanceResponse> completedTodayTasks;

    /**
     * Useful for frontend quick display.
     */
    private List<TaskInstanceResponse> topTasks;

    private Integer overdueCount;
    private Integer dueTodayCount;
    private Integer inProgressCount;
    private Integer inboxCount;
    private Integer completedTodayCount;
    private Integer totalOpenCount;
}