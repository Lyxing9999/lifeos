package com.lifeos.backend.location.api.response;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class LocationBatchIngestResponse {
    private int requestedPoints;
    private int acceptedPoints;
    private int rejectedPoints;
    private String message;
}