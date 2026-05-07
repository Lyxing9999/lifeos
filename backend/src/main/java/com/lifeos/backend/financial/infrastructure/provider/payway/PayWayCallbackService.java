package com.lifeos.backend.financial.infrastructure.provider.payway;

import com.lifeos.backend.financial.application.FinancialIngestionService;
import com.lifeos.backend.financial.domain.*;
import com.lifeos.backend.financial.infrastructure.provider.common.FinancialProviderEvent;
import com.lifeos.backend.financial.infrastructure.provider.payway.log.PayWayCallbackLog;
import com.lifeos.backend.financial.infrastructure.provider.payway.log.PayWayCallbackLogService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class PayWayCallbackService {

    private final FinancialIngestionService ingestionService;
    private final PayWayCallbackLogService callbackLogService;

    public void handle(UUID userId, String timezone, String consentId, PayWayCallbackPayload payload) {
        PayWayCallbackLog callbackLog = callbackLogService.create(
                userId,
                payload,
                payload.getTranId(),
                payload.getMerchantRefNo()
        );

        try {
            log.info("payway_callback_received userId={} tranId={} status={} merchantRefNo={} apv={}",
                    userId, payload.getTranId(), payload.getStatus(), payload.getMerchantRefNo(), payload.getApv());

            FinancialProviderEvent event = new FinancialProviderEvent(
                    userId,
                    BigDecimal.ZERO,
                    "USD",
                    "PayWay Payment",
                    FinancialEventType.PURCHASE,
                    FinancialCategory.OTHER,
                    Instant.now(),
                    timezone,
                    payload.getStatus() != null && payload.getStatus() == 0
                            ? FinancialEventStatus.POSTED
                            : FinancialEventStatus.PENDING,
                    SourceProvider.PAYWAY,
                    payload.getTranId(),
                    null,
                    payload.getTranId(),
                    "PayWay callback / ref=" + payload.getMerchantRefNo(),
                    null,
                    "KH",
                    true,
                    consentId
            );

            ingestionService.ingest(event);
            callbackLogService.markProcessed(callbackLog);
        } catch (Exception ex) {
            callbackLogService.markFailed(callbackLog, ex);
            throw ex;
        }
    }
}