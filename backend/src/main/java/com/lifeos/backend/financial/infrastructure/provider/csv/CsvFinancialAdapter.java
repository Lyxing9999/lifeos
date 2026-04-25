package com.lifeos.backend.financial.infrastructure.provider.csv;

import com.lifeos.backend.financial.domain.*;
import com.lifeos.backend.financial.infrastructure.provider.common.FinancialProviderAdapter;
import com.lifeos.backend.financial.infrastructure.provider.common.FinancialProviderContext;
import com.lifeos.backend.financial.infrastructure.provider.common.FinancialProviderEvent;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.ZoneId;

@Component
public class CsvFinancialAdapter implements FinancialProviderAdapter<CsvFinancialRow> {

    @Override
    public FinancialProviderEvent map(CsvFinancialRow raw, FinancialProviderContext context) {
        return new FinancialProviderEvent(
                context.userId(),
                new BigDecimal(raw.getAmount()),
                raw.getCurrency(),
                raw.getMerchantName(),
                FinancialEventType.PURCHASE,
                null,
                LocalDateTime.parse(raw.getPaidAt()).atZone(ZoneId.of(context.timezone())).toInstant(),
                context.timezone(),
                FinancialEventStatus.POSTED,
                SourceProvider.CSV_IMPORT,
                null,
                null,
                null,
                raw.getDescription(),
                null,
                null,
                true,
                context.consentId()
        );
    }
}