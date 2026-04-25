package com.lifeos.backend.timeline.dto;

import com.lifeos.backend.schedule.api.response.ScheduleOccurrenceResponse;
import com.lifeos.backend.staysession.api.response.StaySessionResponse;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Getter
@Builder
public class TimelineDayResponse {
    private UUID userId;
    private LocalDate date;
    private TimelineSummaryResponse summary;

    // unified chronological stream
    private List<TimelineItemResponse> items;

    // existing buckets for compatibility
    private List<TimelineTaskLiteResponse> tasks;
    private List<ScheduleOccurrenceResponse> schedules;
    private List<StaySessionResponse> staySessions;
    private TimelineFinancialSummaryResponse financialSummary;
    private List<TimelineFinancialLiteResponse> financialEvents;
}