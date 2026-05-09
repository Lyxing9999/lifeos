package com.lifeos.backend.today.api.response;

import com.lifeos.backend.schedule.api.response.ScheduleOccurrenceResponse;
import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
public class TodayScheduleSectionResponse {

    private ScheduleOccurrenceResponse currentSchedule;
    private ScheduleOccurrenceResponse nextSchedule;

    private List<ScheduleOccurrenceResponse> activeNow;
    private List<ScheduleOccurrenceResponse> upcomingToday;
    private List<ScheduleOccurrenceResponse> expiredToday;
    private List<ScheduleOccurrenceResponse> visibleToday;

    private Integer activeNowCount;
    private Integer upcomingTodayCount;
    private Integer expiredTodayCount;
    private Integer visibleTodayCount;
}