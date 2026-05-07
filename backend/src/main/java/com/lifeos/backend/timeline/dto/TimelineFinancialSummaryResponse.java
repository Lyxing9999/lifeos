package com.lifeos.backend.timeline.dto;

import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;

@Getter
@Builder
public class TimelineFinancialSummaryResponse {
    private int totalFinancialEvents;
    private BigDecimal totalOutgoingAmount;
}