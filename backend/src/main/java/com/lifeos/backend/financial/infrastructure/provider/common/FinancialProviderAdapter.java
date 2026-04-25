package com.lifeos.backend.financial.infrastructure.provider.common;

public interface FinancialProviderAdapter<T> {
    FinancialProviderEvent map(T rawPayload, FinancialProviderContext context);
}