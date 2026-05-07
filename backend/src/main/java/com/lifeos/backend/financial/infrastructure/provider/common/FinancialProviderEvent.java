package com.lifeos.backend.financial.infrastructure.provider.common;

import com.lifeos.backend.financial.domain.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public record FinancialProviderEvent(
        UUID userId,
        BigDecimal amount,
        String currency,
        String merchantName,
        FinancialEventType financialEventType,
        FinancialCategory category,
        Instant paidAt,
        String timezone,
        FinancialEventStatus status,
        SourceProvider sourceProvider,
        String providerEventId,
        String sourceAccountIdMasked,
        String rawReference,
        String description,
        String locationText,
        String countryCode,
        Boolean isReadOnly,
        String consentId
) {}