package com.lifeos.backend.place.application;

import com.lifeos.backend.config.GooglePlacesProperties;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class GooglePlaceEnrichmentService {

    private final GooglePlacesProperties properties;
    private final PlaceCacheService placeCacheService;

    public PlaceMatchingResult enrich(double lat, double lng) {
        if (!properties.isEnabled() || properties.getApiKey() == null || properties.getApiKey().isBlank()) {
            return null;
        }

        // Production boundary is correct here.
        // Replace this implementation with real Google Places API call.
        // Keep this service isolated so only this class changes later.

        placeCacheService.save(
                lat,
                lng,
                null,
                "Nearby Place",
                "ESTABLISHMENT",
                null
        );

        log.info("google_place_enriched lat={} lng={}", lat, lng);

        return PlaceMatchingResult.builder()
                .placeName("Nearby Place")
                .placeType("ESTABLISHMENT")
                .source("GOOGLE")
                .confidence(0.75)
                .build();
    }
}