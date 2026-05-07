package com.lifeos.backend.financial.infrastructure.provider.payway.log;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PayWayCallbackLogService {

    private final PayWayCallbackLogRepository repository;
    private final ObjectMapper objectMapper;

    public PayWayCallbackLog create(UUID userId, Object payload, String transactionId, String merchantRefNo) {
        try {
            PayWayCallbackLog log = new PayWayCallbackLog();
            log.setUserId(userId);
            log.setTransactionId(transactionId);
            log.setMerchantRefNo(merchantRefNo);
            log.setRawPayloadJson(objectMapper.writeValueAsString(payload));
            log.setProcessed(false);
            return repository.save(log);
        } catch (Exception e) {
            throw new IllegalStateException("Failed to create PayWay callback log", e);
        }
    }

    public void markProcessed(PayWayCallbackLog callbackLog) {
        callbackLog.setProcessed(true);
        callbackLog.setProcessingError(null);
        repository.save(callbackLog);
    }

    public void markFailed(PayWayCallbackLog callbackLog, Exception ex) {
        callbackLog.setProcessed(false);
        callbackLog.setProcessingError(ex.getMessage());
        repository.save(callbackLog);
    }
}