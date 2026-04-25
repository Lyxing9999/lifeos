package com.lifeos.backend.place.domain;

import com.lifeos.backend.common.base.BaseEntity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Entity
@Table(
        name = "user_places",
        indexes = {
                @Index(name = "idx_user_places_user", columnList = "userId"),
                @Index(name = "idx_user_places_user_name", columnList = "userId,name")
        }
)
@Getter
@Setter
public class UserPlace extends BaseEntity {

    @Column(nullable = false)
    private UUID userId;

    @Column(nullable = false, length = 200)
    private String name;

    @Column(nullable = false, length = 80)
    private String placeType;

    @Column(nullable = false)
    private Double latitude;

    @Column(nullable = false)
    private Double longitude;

    /**
     * Radius used when matching raw/stay coordinates to this place.
     */
    @Column(nullable = false)
    private Double matchRadiusMeters = 120.0;

    @Column(nullable = false)
    private Boolean active = true;
}