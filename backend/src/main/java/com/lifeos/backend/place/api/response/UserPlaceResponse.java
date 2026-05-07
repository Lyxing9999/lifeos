package com.lifeos.backend.place.api.response;

import lombok.Builder;
import lombok.Getter;

import java.util.UUID;

@Getter
@Builder
public class UserPlaceResponse {
    private UUID id;
    private UUID userId;
    private String name;
    private String placeType;
    private Double latitude;
    private Double longitude;
    private Double matchRadiusMeters;
    private Boolean active;
}