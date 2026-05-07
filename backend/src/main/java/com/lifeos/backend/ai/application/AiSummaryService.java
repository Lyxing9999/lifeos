package com.lifeos.backend.ai.application;

import com.lifeos.backend.ai.domain.AiSummaryRequest;
import com.lifeos.backend.ai.domain.AiSummaryResult;
import com.lifeos.backend.ai.infrastructure.client.FastApiAiClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class AiSummaryService {

    private final AiSummaryFallbackService fallbackService;
    private final org.springframework.beans.factory.ObjectProvider<FastApiAiClient> fastApiAiClientProvider;

    public AiSummaryResult generate(AiSummaryRequest request) {
        FastApiAiClient client = fastApiAiClientProvider.getIfAvailable();

        if (client == null) {
            log.info("ai_summary_fallback_used reason=no_fastapi_client");
            return fallbackService.generate(request);
        }

        try {
            AiSummaryResult result = client.generateSummary(request);
            log.info("ai_summary_generated fallbackUsed={}", result.isFallbackUsed());
            return result;
        } catch (Exception ex) {
            log.warn("ai_summary_generation_failed_using_fallback reason={}", ex.getMessage());
            return fallbackService.generate(request);
        }
    }
}