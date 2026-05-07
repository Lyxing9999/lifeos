package com.lifeos.backend.place.domain;

import java.util.Optional;

public interface GooglePlaceCacheRepository {

    Optional<GooglePlaceCache> findByRoundedLatAndRoundedLng(Double roundedLat, Double roundedLng);

    GooglePlaceCache save(GooglePlaceCache cache);
}