package com.lifeos.backend.place.api.response;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class PlaceMatchResponse {
    private String placeName;
    private String placeType;
    private String source;
    private Double confidence;
}