package com.lifeos.backend.place.infrastructure.persistence;

import com.lifeos.backend.place.domain.GooglePlaceCache;
import com.lifeos.backend.place.domain.GooglePlaceCacheRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class GooglePlaceCacheRepositoryImpl implements GooglePlaceCacheRepository {

    private final GooglePlaceCacheJpaRepository jpaRepository;

    @Override
    public Optional<GooglePlaceCache> findByRoundedLatAndRoundedLng(Double roundedLat, Double roundedLng) {
        return jpaRepository.findByRoundedLatAndRoundedLng(roundedLat, roundedLng);
    }

    @Override
    public GooglePlaceCache save(GooglePlaceCache cache) {
        return jpaRepository.save(cache);
    }
}