package com.lifeos.backend.financial.api.response;

import com.lifeos.backend.financial.domain.*;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Getter
@Builder
public class FinancialEventResponse {
    private UUID id;
    private UUID userId;
    private BigDecimal amount;
    private String currency;
    private String merchantName;
    private String normalizedMerchantName;
    private Double merchantConfidence;
    private FinancialEventType financialEventType;
    private FinancialCategory category;
    private Instant paidAt;
    private LocalDate eventDateLocal;
    private String timezone;
    private FinancialEventStatus status;
    private SourceProvider sourceProvider;
    private String providerEventId;
    private String sourceAccountIdMasked;
    private String rawReference;
    private String description;
    private String locationText;
    private String countryCode;
    private Boolean isReadOnly;
    private String consentId;
}