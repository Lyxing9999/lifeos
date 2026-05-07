package com.lifeos.backend.place.api.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UpdateUserPlaceRequest {
    private String name;
    private String placeType;
    private Double latitude;
    private Double longitude;
    private Double matchRadiusMeters;
    private Boolean active;
}