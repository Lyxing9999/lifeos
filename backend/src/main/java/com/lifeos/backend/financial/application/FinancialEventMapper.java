package com.lifeos.backend.financial.application;

import com.lifeos.backend.financial.api.response.FinancialEventResponse;
import com.lifeos.backend.financial.domain.FinancialEvent;
import org.springframework.stereotype.Component;

@Component
public class FinancialEventMapper {

    public FinancialEventResponse toResponse(FinancialEvent e) {
        return FinancialEventResponse.builder()
                .id(e.getId())
                .userId(e.getUserId())
                .amount(e.getAmount())
                .currency(e.getCurrency())
                .merchantName(e.getMerchantName())
                .normalizedMerchantName(e.getNormalizedMerchantName())
                .merchantConfidence(e.getMerchantConfidence())
                .financialEventType(e.getFinancialEventType())
                .category(e.getCategory())
                .paidAt(e.getPaidAt())
                .eventDateLocal(e.getEventDateLocal())
                .timezone(e.getTimezone())
                .status(e.getStatus())
                .sourceProvider(e.getSourceProvider())
                .providerEventId(e.getProviderEventId())
                .sourceAccountIdMasked(e.getSourceAccountIdMasked())
                .rawReference(e.getRawReference())
                .description(e.getDescription())
                .locationText(e.getLocationText())
                .countryCode(e.getCountryCode())
                .isReadOnly(e.getIsReadOnly())
                .consentId(e.getConsentId())
                .build();
    }
}