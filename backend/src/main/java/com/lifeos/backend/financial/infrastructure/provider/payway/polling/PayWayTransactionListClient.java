package com.lifeos.backend.financial.infrastructure.provider.payway.polling;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.lifeos.backend.common.config.PayWayProperties;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import okhttp3.*;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
@ConditionalOnProperty(prefix = "lifeos.payway", name = "enabled", havingValue = "true")
public class PayWayTransactionListClient {

    private final PayWayProperties properties;
    private final ObjectMapper objectMapper;

    public PayWayTransactionListResponse fetch(PayWayTransactionListRequest request) {
        try {
            OkHttpClient client = new OkHttpClient.Builder().build();

            String json = objectMapper.writeValueAsString(request);

            RequestBody body = RequestBody.create(
                    json,
                    MediaType.parse("application/json")
            );

            Request httpRequest = new Request.Builder()
                    .url(properties.getBaseUrl() + "/api/payment-gateway/v1/payments/transaction-list-2")
                    .post(body)
                    .addHeader("Content-Type", "application/json")
                    .build();

            try (Response response = client.newCall(httpRequest).execute()) {
                if (response.body() == null) {
                    throw new IllegalStateException("Empty PayWay transaction-list response");
                }

                String raw = response.body().string();
                log.info("payway_transaction_list_http_status={}", response.code());
                log.info("payway_transaction_list_response={}", raw);

                return objectMapper.readValue(raw, PayWayTransactionListResponse.class);
            }
        } catch (Exception ex) {
            throw new IllegalStateException("Failed to fetch PayWay transaction list", ex);
        }
    }
}