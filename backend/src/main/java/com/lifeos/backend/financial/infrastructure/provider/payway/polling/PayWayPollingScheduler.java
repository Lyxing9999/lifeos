package com.lifeos.backend.financial.infrastructure.provider.payway.polling;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
@ConditionalOnProperty(prefix = "lifeos.payway.polling", name = "enabled", havingValue = "true")
public class PayWayPollingScheduler {

    @Scheduled(cron = "0 */15 * * * *")
    public void run() {
        log.info("payway_polling_scheduler_tick");
        // later:
        // - loop opted-in users
        // - poll last 1 day
        // - upsert by providerEventId
    }
}