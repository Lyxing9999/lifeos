package com.lifeos.backend.place.application;

import com.lifeos.backend.place.api.request.CreateUserPlaceRequest;
import com.lifeos.backend.place.api.response.UserPlaceResponse;
import com.lifeos.backend.place.domain.UserPlace;
import org.springframework.stereotype.Component;

@Component
public class UserPlaceMapper {

    public UserPlace toEntity(CreateUserPlaceRequest request) {
        UserPlace place = new UserPlace();
        place.setUserId(request.getUserId());
        place.setName(request.getName());
        place.setPlaceType(request.getPlaceType());
        place.setLatitude(request.getLatitude());
        place.setLongitude(request.getLongitude());
        place.setMatchRadiusMeters(
                request.getMatchRadiusMeters() != null ? request.getMatchRadiusMeters() : 120.0
        );
        place.setActive(true);
        return place;
    }

    public UserPlaceResponse toResponse(UserPlace place) {
        return UserPlaceResponse.builder()
                .id(place.getId())
                .userId(place.getUserId())
                .name(place.getName())
                .placeType(place.getPlaceType())
                .latitude(place.getLatitude())
                .longitude(place.getLongitude())
                .matchRadiusMeters(place.getMatchRadiusMeters())
                .active(place.getActive())
                .build();
    }
}