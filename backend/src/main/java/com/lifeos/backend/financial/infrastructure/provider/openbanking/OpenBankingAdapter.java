package com.lifeos.backend.financial.infrastructure.provider.openbanking;

import com.lifeos.backend.financial.domain.FinancialEventStatus;
import com.lifeos.backend.financial.domain.FinancialEventType;
import com.lifeos.backend.financial.domain.SourceProvider;
import com.lifeos.backend.financial.infrastructure.provider.common.FinancialProviderAdapter;
import com.lifeos.backend.financial.infrastructure.provider.common.FinancialProviderContext;
import com.lifeos.backend.financial.infrastructure.provider.common.FinancialProviderEvent;
import org.springframework.stereotype.Component;

@Component
public class OpenBankingAdapter implements FinancialProviderAdapter<OpenBankingTransactionRow> {

    @Override
    public FinancialProviderEvent map(OpenBankingTransactionRow raw, FinancialProviderContext context) {
        return new FinancialProviderEvent(
                context.userId(),
                raw.getAmount(),
                raw.getCurrency(),
                raw.getMerchantName() != null ? raw.getMerchantName() : "Bank Transaction",
                FinancialEventType.PURCHASE,
                null,
                raw.getBookedAt(),
                context.timezone(),
                FinancialEventStatus.POSTED,
                SourceProvider.OPEN_BANKING,
                raw.getProviderTransactionId(),
                raw.getAccountMasked(),
                raw.getRawReference(),
                raw.getDescription(),
                null,
                raw.getCountryCode(),
                true,
                context.consentId()
        );
    }
}