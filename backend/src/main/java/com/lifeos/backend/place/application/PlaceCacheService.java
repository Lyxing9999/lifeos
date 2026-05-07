package com.lifeos.backend.place.application;

import com.lifeos.backend.place.domain.GooglePlaceCache;
import com.lifeos.backend.place.domain.GooglePlaceCacheRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class PlaceCacheService {

    private final GooglePlaceCacheRepository repository;

    public Optional<GooglePlaceCache> find(double lat, double lng) {
        return repository.findByRoundedLatAndRoundedLng(round(lat), round(lng));
    }

    public GooglePlaceCache save(
            double lat,
            double lng,
            String placeId,
            String placeName,
            String placeType,
            String address
    ) {
        GooglePlaceCache cache = new GooglePlaceCache();
        cache.setRoundedLat(round(lat));
        cache.setRoundedLng(round(lng));
        cache.setPlaceId(placeId);
        cache.setPlaceName(placeName);
        cache.setPlaceType(placeType);
        cache.setAddress(address);
        return repository.save(cache);
    }

    private double round(double value) {
        return Math.round(value * 1000.0) / 1000.0;
    }
}