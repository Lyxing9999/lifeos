package com.lifeos.backend.today.api.response;

import com.lifeos.backend.score.api.response.DailyScoreResponse;
import com.lifeos.backend.summary.api.response.DailySummaryResponse;
import com.lifeos.backend.timeline.api.response.TimelineDayResponse;
import com.lifeos.backend.user.api.response.UserResponse;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.util.UUID;

@Getter
@Builder
public class TodayWorkspaceResponse {

    private UUID userId;
    private LocalDate date;

    private UserResponse user;

    private TodayContextResponse context;
    private String greeting;

    private TodayCurrentFocusResponse currentFocus;

    private TodayTaskSectionResponse tasks;
    private TodayScheduleSectionResponse schedule;

    /**
     * Optional past-truth preview.
     * This now comes from Timeline ledger, not old dynamic TimelineService.
     */
    private TimelineDayResponse timelinePreview;

    /**
     * Optional domains.
     */
    private DailySummaryResponse summary;
    private DailyScoreResponse score;

    private TodayCountsResponse counts;
}