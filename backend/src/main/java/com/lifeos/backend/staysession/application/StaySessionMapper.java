package com.lifeos.backend.staysession.application;

import com.lifeos.backend.staysession.api.response.StaySessionResponse;
import com.lifeos.backend.staysession.domain.StaySession;
import org.springframework.stereotype.Component;

@Component
public class StaySessionMapper {

    public StaySessionResponse toResponse(StaySession session) {
        return StaySessionResponse.builder()
                .id(session.getId())
                .userId(session.getUserId())
                .startTime(session.getStartTime())
                .endTime(session.getEndTime())
                .durationMinutes(session.getDurationMinutes())
                .placeName(session.getPlaceName())
                .placeType(session.getPlaceType())
                .matchedPlaceSource(session.getMatchedPlaceSource())
                .confidence(session.getConfidence())
                .centerLat(session.getCenterLat())
                .centerLng(session.getCenterLng())
                .build();
    }
}