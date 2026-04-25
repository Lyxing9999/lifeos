package com.lifeos.backend.staysession.api.response;

import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.UUID;

@Getter
@Builder
public class StaySessionResponse {
    private UUID id;
    private UUID userId;
    private Instant startTime;
    private Instant endTime;
    private Long durationMinutes;
    private String placeName;
    private String placeType;
    private String matchedPlaceSource;
    private Double confidence;
    private Double centerLat;
    private Double centerLng;
}