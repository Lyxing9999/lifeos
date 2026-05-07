package com.lifeos.backend.task.api.response;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class TaskCountSummaryResponse {
    private int total;
    private int active;
    private int completed;
    private int urgent;
    private int daily;
    private int progress;
}