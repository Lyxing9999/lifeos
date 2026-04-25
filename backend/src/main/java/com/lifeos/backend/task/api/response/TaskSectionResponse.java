package com.lifeos.backend.task.api.response;

import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
public class TaskSectionResponse {
    private List<TaskResponse> urgentTasks;
    private List<TaskResponse> dailyTasks;
    private List<TaskResponse> progressTasks;
    private List<TaskResponse> standardTasks;
}