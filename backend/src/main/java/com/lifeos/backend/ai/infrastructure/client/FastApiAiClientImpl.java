package com.lifeos.backend.ai.infrastructure.client;

import com.lifeos.backend.ai.domain.AiSummaryRequest;
import com.lifeos.backend.ai.domain.AiSummaryResult;
import com.lifeos.backend.common.config.AiServiceProperties;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

@Component
@RequiredArgsConstructor
@ConditionalOnProperty(prefix = "lifeos.ai", name = "enabled", havingValue = "true")
@Slf4j
public class FastApiAiClientImpl implements FastApiAiClient {

    private final AiServiceProperties properties;

    @Override
    public AiSummaryResult generateSummary(AiSummaryRequest request) {
        RestClient client = RestClient.builder()
                .baseUrl(properties.getBaseUrl())
                .build();

        log.info("calling_fastapi_ai baseUrl={} request={}", properties.getBaseUrl(), request);

        return client.post()
                .uri("/v1/summary/daily")
                .contentType(MediaType.APPLICATION_JSON)
                .body(request)
                .retrieve()
                .body(AiSummaryResult.class);
    }
}