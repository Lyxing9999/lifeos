package com.lifeos.backend.financial.api.response;

import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;

@Getter
@Builder
public class FinancialSummaryResponse {
    private Integer totalFinancialEvents;
    private BigDecimal totalOutgoingAmount;
    private String latestMerchantName;
    private BigDecimal latestAmount;
    private String latestCurrency;
}