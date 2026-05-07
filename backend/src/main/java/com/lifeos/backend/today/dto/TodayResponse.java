package com.lifeos.backend.today.dto;

import com.lifeos.backend.score.api.response.DailyScoreResponse;
import com.lifeos.backend.summary.api.response.DailySummaryResponse;
import com.lifeos.backend.timeline.dto.TimelineDayResponse;
import com.lifeos.backend.timeline.dto.TimelineTaskLiteResponse;
import com.lifeos.backend.user.api.response.UserResponse;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;

@Getter
@Builder
public class TodayResponse {
    private UserResponse user;
    private LocalDate date;
    private String contextualGreeting; // NEW FEATURE: AI-like dynamic greeting

    private DailySummaryResponse summary;
    private DailyScoreResponse score;
    private TimelineDayResponse timeline;

    private TodayCurrentScheduleResponse currentScheduleBlock;
    private TimelineTaskLiteResponse topActiveTask; // Reused Lite DTO to save memory
    private TodayPlaceInsightResponse topPlaceInsight;

    // TODO: Uncomment when Finance module is fully implemented
    // private TodayFinancialInsightResponse financialInsight;
}