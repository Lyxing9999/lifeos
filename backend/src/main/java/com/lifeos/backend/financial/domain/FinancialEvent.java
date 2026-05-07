package com.lifeos.backend.financial.domain;

import com.lifeos.backend.common.base.BaseEntity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(
        name = "financial_events",
        indexes = {
                @Index(name = "idx_financial_events_user_date", columnList = "userId,eventDateLocal"),
                @Index(name = "idx_financial_events_user_paidAt", columnList = "userId,paidAt"),
                @Index(name = "idx_financial_events_provider_event", columnList = "userId,providerEventId", unique = true)
        }
)
@Getter
@Setter
public class FinancialEvent extends BaseEntity {

    @Column(nullable = false)
    private UUID userId;

    @Column(nullable = false, precision = 18, scale = 4)
    private BigDecimal amount;

    @Column(nullable = false, length = 3)
    private String currency;

    @Column(nullable = false)
    private String merchantName;

    private String normalizedMerchantName;

    private Double merchantConfidence;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private FinancialEventType financialEventType;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private FinancialCategory category;

    @Column(nullable = false)
    private Instant paidAt;

    @Column(nullable = false)
    private LocalDate eventDateLocal;

    @Column(nullable = false)
    private String timezone;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private FinancialEventStatus status;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SourceProvider sourceProvider;

    private String providerEventId;
    private String sourceAccountIdMasked;
    private String rawReference;

    @Column(length = 1000)
    private String description;

    private String locationText;
    private String countryCode;

    @Column(nullable = false)
    private Boolean isReadOnly = true;

    private String consentId;
}