package com.lifeos.backend.financial.infrastructure.provider.payway.polling;

import com.lifeos.backend.financial.domain.*;
import com.lifeos.backend.financial.infrastructure.provider.common.FinancialProviderAdapter;
import com.lifeos.backend.financial.infrastructure.provider.common.FinancialProviderContext;
import com.lifeos.backend.financial.infrastructure.provider.common.FinancialProviderEvent;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.*;
import java.time.format.DateTimeFormatter;

@Component
public class PayWayTransactionMapper implements FinancialProviderAdapter<PayWayTransactionListResponse.Item> {

    private static final DateTimeFormatter PAYWAY_DATE_TIME =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    @Override
    public FinancialProviderEvent map(PayWayTransactionListResponse.Item raw, FinancialProviderContext context) {
        return new FinancialProviderEvent(
                context.userId(),
                resolveAmount(raw),
                resolveCurrency(raw),
                resolveMerchantName(raw),
                mapEventType(raw.getPaymentStatus()),
                resolveCategory(raw),
                resolvePaidAt(raw, context.timezone()),
                context.timezone(),
                mapStatus(raw.getPaymentStatus()),
                SourceProvider.PAYWAY,
                raw.getTransactionId(),
                raw.getPayerAccount(),
                resolveRawReference(raw),
                resolveDescription(raw),
                raw.getBankName(),
                "KH",
                true,
                context.consentId()
        );
    }

    private BigDecimal resolveAmount(PayWayTransactionListResponse.Item raw) {
        if (raw.getTotalAmount() != null) return raw.getTotalAmount();
        if (raw.getOriginalAmount() != null) return raw.getOriginalAmount();
        return BigDecimal.ZERO;
    }

    private String resolveCurrency(PayWayTransactionListResponse.Item raw) {
        if (raw.getOriginalCurrency() != null && !raw.getOriginalCurrency().isBlank()) {
            return raw.getOriginalCurrency();
        }
        if (raw.getPaymentCurrency() != null && !raw.getPaymentCurrency().isBlank()) {
            return raw.getPaymentCurrency();
        }
        return "USD";
    }

    private String resolveMerchantName(PayWayTransactionListResponse.Item raw) {
        if (raw.getBankName() != null && !raw.getBankName().isBlank()) {
            return "PayWay " + raw.getBankName();
        }
        if (raw.getPaymentType() != null && !raw.getPaymentType().isBlank()) {
            return "PayWay " + raw.getPaymentType();
        }
        return "PayWay Payment";
    }

    private FinancialCategory resolveCategory(PayWayTransactionListResponse.Item raw) {
        String text = ((raw.getPaymentType() == null ? "" : raw.getPaymentType()) + " " +
                (raw.getBankName() == null ? "" : raw.getBankName())).toLowerCase();

        if (text.contains("khqr")) return FinancialCategory.OTHER;
        if (text.contains("visa") || text.contains("mc") || text.contains("jcb")) return FinancialCategory.OTHER;
        return FinancialCategory.OTHER;
    }

    private Instant resolvePaidAt(PayWayTransactionListResponse.Item raw, String timezone) {
        if (raw.getTransactionDate() == null || raw.getTransactionDate().isBlank()) {
            return Instant.now();
        }
        LocalDateTime local = LocalDateTime.parse(raw.getTransactionDate(), PAYWAY_DATE_TIME);
        return local.atZone(ZoneId.of(timezone)).toInstant();
    }

    private FinancialEventType mapEventType(String paymentStatus) {
        String s = safeUpper(paymentStatus);
        return switch (s) {
            case "APPROVED", "PRE-AUTH", "PENDING" -> FinancialEventType.PURCHASE;
            case "REFUNDED" -> FinancialEventType.REFUND;
            default -> FinancialEventType.OTHER;
        };
    }

    private FinancialEventStatus mapStatus(String paymentStatus) {
        String s = safeUpper(paymentStatus);
        return switch (s) {
            case "APPROVED", "REFUNDED" -> FinancialEventStatus.POSTED;
            case "PRE-AUTH", "PENDING" -> FinancialEventStatus.PENDING;
            case "DECLINED", "CANCELLED" -> FinancialEventStatus.REVERSED;
            default -> FinancialEventStatus.PENDING;
        };
    }

    private String resolveRawReference(PayWayTransactionListResponse.Item raw) {
        if (raw.getBankRef() != null && !raw.getBankRef().isBlank()) return raw.getBankRef();
        return raw.getTransactionId();
    }

    private String resolveDescription(PayWayTransactionListResponse.Item raw) {
        StringBuilder sb = new StringBuilder();
        if (raw.getPaymentType() != null && !raw.getPaymentType().isBlank()) {
            sb.append(raw.getPaymentType());
        }
        if (raw.getBankName() != null && !raw.getBankName().isBlank()) {
            if (sb.length() > 0) sb.append(" via ");
            sb.append(raw.getBankName());
        }
        if (raw.getApv() != null && !raw.getApv().isBlank()) {
            if (sb.length() > 0) sb.append(" / ");
            sb.append("apv=").append(raw.getApv());
        }
        return sb.length() == 0 ? "PayWay polled transaction" : sb.toString();
    }

    private String safeUpper(String value) {
        return value == null ? "" : value.trim().toUpperCase();
    }
}