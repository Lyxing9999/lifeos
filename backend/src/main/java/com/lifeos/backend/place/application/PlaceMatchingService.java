package com.lifeos.backend.place.application;

import com.lifeos.backend.place.domain.UserPlace;
import com.lifeos.backend.place.domain.UserPlaceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PlaceMatchingService {

    private final UserPlaceRepository userPlaceRepository;
    private final PlaceCacheService placeCacheService;
    private final GooglePlaceEnrichmentService googlePlaceEnrichmentService;

    public PlaceMatchingResult match(UUID userId, double lat, double lng, long durationMinutes) {
        PlaceMatchingResult userPlaceMatch = matchUserPlace(userId, lat, lng);
        if (userPlaceMatch != null) {
            return userPlaceMatch;
        }

        PlaceMatchingResult cachedMatch = placeCacheService.find(lat, lng)
                .map(cache -> PlaceMatchingResult.builder()
                        .placeName(cache.getPlaceName())
                        .placeType(cache.getPlaceType())
                        .source("GOOGLE")
                        .confidence(0.8)
                        .build())
                .orElse(null);

        if (cachedMatch != null) {
            return cachedMatch;
        }

        if (durationMinutes >= 15) {
            PlaceMatchingResult googleMatch = googlePlaceEnrichmentService.enrich(lat, lng);
            if (googleMatch != null) {
                return googleMatch;
            }
        }

        return PlaceMatchingResult.builder()
                .placeName("Unknown Place")
                .placeType("OTHER")
                .source("UNKNOWN")
                .confidence(0.2)
                .build();
    }

    private PlaceMatchingResult matchUserPlace(UUID userId, double lat, double lng) {
        List<UserPlace> places = userPlaceRepository.findByUserIdAndActiveTrue(userId);

        return places.stream()
                .map(place -> new MatchCandidate(place, distanceMeters(lat, lng, place.getLatitude(), place.getLongitude())))
                .filter(candidate -> candidate.distanceMeters() <= candidate.place().getMatchRadiusMeters())
                .min(Comparator.comparingDouble(MatchCandidate::distanceMeters))
                .map(candidate -> PlaceMatchingResult.builder()
                        .placeName(candidate.place().getName())
                        .placeType(candidate.place().getPlaceType())
                        .source("USER_PLACE")
                        .confidence(0.95)
                        .build())
                .orElse(null);
    }

    private double distanceMeters(double lat1, double lng1, double lat2, double lng2) {
        double earthRadius = 6371000.0;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);
        double a =
                Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                        Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                                Math.sin(dLng / 2) * Math.sin(dLng / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return earthRadius * c;
    }

    private record MatchCandidate(UserPlace place, double distanceMeters) {}
}