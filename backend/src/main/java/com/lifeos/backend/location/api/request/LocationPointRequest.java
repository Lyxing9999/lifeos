package com.lifeos.backend.location.api.request;

import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Getter
@Setter
public class LocationPointRequest {
    private Double latitude;
    private Double longitude;
    private Double accuracyMeters;
    private Double speedMetersPerSecond;
    private Instant recordedAt;
    private String source;
}