package com.lifeos.backend.today.api.response;

import com.lifeos.backend.schedule.api.response.ScheduleOccurrenceResponse;
import com.lifeos.backend.task.api.response.TaskInstanceResponse;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class TodayCurrentFocusResponse {

    /**
     * TASK, SCHEDULE, TASK_IN_SCHEDULE, FREE_TIME, REST, NONE
     */
    private String focusType;

    private String title;
    private String subtitle;
    private String reason;

    private Boolean activeNow;
    private Boolean urgent;
    private Boolean blockedBySchedule;

    private TaskInstanceResponse task;
    private ScheduleOccurrenceResponse schedule;
}