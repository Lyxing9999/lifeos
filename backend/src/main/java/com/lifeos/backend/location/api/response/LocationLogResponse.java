package com.lifeos.backend.location.api.response;

import lombok.Builder;
import lombok.Getter;

import java.time.Instant;
import java.util.UUID;

@Getter
@Builder
public class LocationLogResponse {
    private UUID id;
    private UUID userId;
    private Double latitude;
    private Double longitude;
    private Double accuracyMeters;
    private Double speedMetersPerSecond;
    private Instant recordedAt;
    private String source;
}