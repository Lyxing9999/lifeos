package com.lifeos.backend.timeline.api.response;

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
    private String timezone;

    private TimelineSummaryResponse summary;

    private List<TimelineEntryResponse> items;
}