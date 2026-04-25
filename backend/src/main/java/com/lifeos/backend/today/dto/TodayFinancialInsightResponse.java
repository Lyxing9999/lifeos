package com.lifeos.backend.today.dto;

import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;

@Getter
@Builder
public class TodayFinancialInsightResponse {
    private int totalEvents;
    private BigDecimal totalOutgoingAmount;
    private String latestMerchantName;
    private BigDecimal latestAmount;
    private String latestCurrency;
}