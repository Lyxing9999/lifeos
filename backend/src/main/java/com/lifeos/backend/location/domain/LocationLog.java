package com.lifeos.backend.location.domain;

import com.lifeos.backend.common.base.BaseEntity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(
        name = "location_logs",
        indexes = {
                @Index(name = "idx_location_logs_user_recorded_at", columnList = "userId,recordedAt"),
                @Index(name = "idx_location_logs_user_created_at", columnList = "userId,createdAt")
        }
)
@Getter
@Setter
public class LocationLog extends BaseEntity {

    @Column(nullable = false)
    private UUID userId;

    @Column(nullable = false)
    private Double latitude;

    @Column(nullable = false)
    private Double longitude;

    @Column(nullable = false)
    private Double accuracyMeters;

    private Double speedMetersPerSecond;

    @Column(nullable = false)
    private Instant recordedAt;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 40)
    private LocationSource source = LocationSource.MOBILE_BACKGROUND;
}