package com.lifeos.backend.financial.infrastructure.provider.payway;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class PayWayReconciliationService {

    public void reconcileByProviderEventId(String tranId) {
        log.info("payway_reconciliation_requested tranId={}", tranId);
    }
}