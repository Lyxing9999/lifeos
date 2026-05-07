package com.lifeos.backend.location.api.request;

import lombok.Getter;
import lombok.Setter;

import java.util.List;
import java.util.UUID;

@Getter
@Setter
public class LocationBatchRequest {
    private UUID userId;
    private List<LocationPointRequest> points;
}