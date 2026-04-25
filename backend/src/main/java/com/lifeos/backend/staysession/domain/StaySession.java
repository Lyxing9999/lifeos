package com.lifeos.backend.staysession.domain;

import com.lifeos.backend.common.base.BaseEntity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(
        name = "stay_sessions",
        indexes = {
                @Index(name = "idx_stay_sessions_user_start", columnList = "userId,startTime"),
                @Index(name = "idx_stay_sessions_user_end", columnList = "userId,endTime"),
                @Index(name = "idx_stay_sessions_user_created", columnList = "userId,createdAt")
        }
)
@Getter
@Setter
public class StaySession extends BaseEntity {

    @Column(nullable = false)
    private UUID userId;

    @Column(nullable = false)
    private Instant startTime;

    @Column(nullable = false)
    private Instant endTime;

    @Column(nullable = false)
    private Long durationMinutes;

    @Column(nullable = false)
    private Double centerLat;

    @Column(nullable = false)
    private Double centerLng;

    @Column(length = 200)
    private String placeName;

    @Column(length = 80)
    private String placeType;

    /**
     * USER_PLACE / GOOGLE / UNKNOWN
     */
    @Column(length = 40)
    private String matchedPlaceSource;

    @Column(nullable = false)
    private Double confidence = 0.0;
}