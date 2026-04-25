package com.lifeos.backend.place.infrastructure.persistence;

import com.lifeos.backend.place.domain.GooglePlaceCache;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface GooglePlaceCacheJpaRepository extends JpaRepository<GooglePlaceCache, UUID> {

    Optional<GooglePlaceCache> findByRoundedLatAndRoundedLng(Double roundedLat, Double roundedLng);
}