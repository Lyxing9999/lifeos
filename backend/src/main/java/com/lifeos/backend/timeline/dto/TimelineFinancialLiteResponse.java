package com.lifeos.backend.timeline.dto;

import com.lifeos.backend.financial.domain.FinancialCategory;
import com.lifeos.backend.financial.domain.FinancialEventType;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Getter
@Builder
public class TimelineFinancialLiteResponse {
    private UUID id;
    private BigDecimal amount;
    private String currency;
    private String merchantName;
    private FinancialEventType financialEventType;
    private FinancialCategory category;
    private Instant paidAt;
}