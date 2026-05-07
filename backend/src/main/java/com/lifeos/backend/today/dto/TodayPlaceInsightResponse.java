package com.lifeos.backend.today.dto;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class TodayPlaceInsightResponse {
    private String placeName;
    private String placeType;
    private Long durationMinutes;
    private String source;
}