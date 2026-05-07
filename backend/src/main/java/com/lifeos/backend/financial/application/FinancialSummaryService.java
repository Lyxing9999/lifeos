package com.lifeos.backend.financial.application;

import com.lifeos.backend.financial.api.response.FinancialEventResponse;
import com.lifeos.backend.financial.api.response.FinancialSummaryResponse;
import com.lifeos.backend.financial.domain.FinancialEventType;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.ZoneId;
import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class FinancialSummaryService {

    private final FinancialEventService financialEventService;

    public List<FinancialEventResponse> getFinancialEventsForDay(UUID userId, LocalDate date, ZoneId zoneId) {
        return financialEventService.getByUserIdAndDay(userId, date, zoneId.toString());
    }

    public BigDecimal totalOutgoing(List<FinancialEventResponse> events) {
        return events.stream()
                .filter(item -> item.getFinancialEventType() == FinancialEventType.PURCHASE
                        || item.getFinancialEventType() == FinancialEventType.CASH_OUT
                        || item.getFinancialEventType() == FinancialEventType.FEE)
                .map(FinancialEventResponse::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    public FinancialEventResponse latest(List<FinancialEventResponse> events) {
        return events.stream()
                .max(Comparator.comparing(FinancialEventResponse::getPaidAt))
                .orElse(null);
    }

    public FinancialSummaryResponse buildSummary(List<FinancialEventResponse> events) {
        BigDecimal totalOutgoing = totalOutgoing(events);
        FinancialEventResponse latest = latest(events);

        return FinancialSummaryResponse.builder()
                .totalFinancialEvents(events.size())
                .totalOutgoingAmount(totalOutgoing)
                .latestMerchantName(latest != null ? latest.getMerchantName() : null)
                .latestAmount(latest != null ? latest.getAmount() : null)
                .latestCurrency(latest != null ? latest.getCurrency() : null)
                .build();
    }

    public String buildDailySpendingSentence(List<FinancialEventResponse> events) {
        if (events == null || events.isEmpty()) {
            return "";
        }

        BigDecimal totalOutgoing = totalOutgoing(events);
        FinancialEventResponse latest = latest(events);

        if (latest == null) {
            return "You had " + events.size() + " financial events today.";
        }

        return "You had " + events.size()
                + " financial events today, with total outgoing "
                + totalOutgoing
                + " "
                + latest.getCurrency()
                + ". Latest merchant was "
                + latest.getMerchantName()
                + ".";
    }
}