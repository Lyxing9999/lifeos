package com.lifeos.backend.place.api.request;

import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
public class CreateUserPlaceRequest {
    private UUID userId;
    private String name;
    private String placeType;
    private Double latitude;
    private Double longitude;
    private Double matchRadiusMeters;
}