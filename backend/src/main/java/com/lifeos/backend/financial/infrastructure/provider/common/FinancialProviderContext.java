package com.lifeos.backend.financial.infrastructure.provider.common;

import java.util.UUID;

public record FinancialProviderContext(
        UUID userId,
        String timezone,
        String consentId
) {}