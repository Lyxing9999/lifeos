package com.lifeos.backend.place.domain;

import com.lifeos.backend.common.base.BaseEntity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(
        name = "google_place_cache",
        indexes = {
                @Index(name = "idx_google_place_cache_rounding", columnList = "roundedLat,roundedLng", unique = true)
        }
)
@Getter
@Setter
public class GooglePlaceCache extends BaseEntity {

    @Column(nullable = false)
    private Double roundedLat;

    @Column(nullable = false)
    private Double roundedLng;

    @Column(length = 255)
    private String placeId;

    @Column(length = 255)
    private String placeName;

    @Column(length = 80)
    private String placeType;

    @Column(length = 255)
    private String address;
}